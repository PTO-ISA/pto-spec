"""Neutral parser and shape helpers for fail-closed workflow contracts."""

from __future__ import annotations

import hashlib
import json
import re


UPLOAD_ARTIFACT_SHA = "ea165f8d65b6e75b540449e92b4886f43607fa02"
DOWNLOAD_ARTIFACT_SHA = "95815c38cf2ff2164869cbab79da8d1f422bc89e"
CACHE_ACTION_SHA = "55cc8345863c7cc4c66a329aec7e433d2d1c52a9"
CHECKOUT_ACTION_SHA = "d23441a48e516b6c34aea4fa41551a30e30af803"
OCAML_ACTION_SHA = "15d660006c1d3110d77c34b7faa3bddefe8b82f0"
SETUP_NODE_ACTION_SHA = "2028fbc5c25fe9cf00d9f06a71cc4710d4507903"
YAML_ANCHOR_OR_ALIAS = re.compile(
    r"^[ \t]*(?:-[ \t]+)?(?:[A-Za-z0-9_-]+:[ \t]+)?"
    r"[&*][^ \t#\[\]{},]+(?:[ \t]+|$)",
    re.MULTILINE,
)


class WorkflowSyntaxError(ValueError):
    pass


def _unique_flow_mapping(pairs: list[tuple[str, object]]) -> dict[str, object]:
    result: dict[str, object] = {}
    for key, value in pairs:
        if key in result:
            raise WorkflowSyntaxError(f"duplicate flow mapping key {key!r}")
        result[key] = value
    return result


def _strip_yaml_comment(value: str) -> str:
    quote: str | None = None
    escaped = False
    for index, character in enumerate(value):
        if escaped:
            escaped = False
            continue
        if character == "\\" and quote == '"':
            escaped = True
            continue
        if character in ("'", '"'):
            if quote is None:
                quote = character
            elif quote == character:
                quote = None
            continue
        if character == "#" and quote is None and (
            index == 0 or value[index - 1].isspace()
        ):
            return value[:index].rstrip()
    return value.rstrip()


class WorkflowSubsetParser:
    """Parse the mapping, sequence, scalar, and block subset used by workflows."""

    KEY = re.compile(r"^(?P<key>[A-Za-z_][A-Za-z0-9_-]*):(?:[ \t]*(?P<value>.*))?$")

    def __init__(self, source: str):
        self.lines = source.splitlines()
        self.index = 0

    def parse(self) -> dict[str, object]:
        value = self._parse_mapping(0)
        self._skip_ignored()
        if self.index != len(self.lines):
            raise WorkflowSyntaxError(
                f"unsupported workflow syntax at line {self.index + 1}"
            )
        return value

    def _skip_ignored(self) -> None:
        while self.index < len(self.lines):
            stripped = self.lines[self.index].strip()
            if stripped and not stripped.startswith("#"):
                break
            self.index += 1

    def _current(self) -> tuple[int, str]:
        raw = self.lines[self.index]
        if "\t" in raw[: len(raw) - len(raw.lstrip())]:
            raise WorkflowSyntaxError(f"tabs are not supported at line {self.index + 1}")
        indentation = len(raw) - len(raw.lstrip(" "))
        return indentation, _strip_yaml_comment(raw[indentation:])

    def _parse_mapping(self, indentation: int) -> dict[str, object]:
        result: dict[str, object] = {}
        while True:
            self._skip_ignored()
            if self.index >= len(self.lines):
                break
            current_indent, content = self._current()
            if current_indent < indentation:
                break
            if current_indent != indentation or content.startswith("- "):
                raise WorkflowSyntaxError(f"malformed mapping at line {self.index + 1}")
            self._parse_mapping_entry(result, indentation, content)
        return result

    def _parse_mapping_entry(
        self, result: dict[str, object], indentation: int, content: str
    ) -> None:
        match = self.KEY.fullmatch(content)
        if match is None:
            raise WorkflowSyntaxError(f"malformed mapping at line {self.index + 1}")
        key = match.group("key")
        if key in result:
            raise WorkflowSyntaxError(f"duplicate mapping key {key!r}")
        value = (match.group("value") or "").strip()
        self.index += 1
        if value.startswith(">"):
            raise WorkflowSyntaxError(
                f"folded block scalars are not supported at line {self.index}"
            )
        if value == "|":
            result[key] = self._parse_block(indentation).rstrip("\n")
            return
        if value.startswith("|"):
            raise WorkflowSyntaxError(
                f"literal block modifiers are not supported at line {self.index}"
            )
        if value:
            result[key] = self._parse_scalar(value)
            return
        self._skip_ignored()
        if self.index >= len(self.lines):
            result[key] = None
            return
        next_indent, next_content = self._current()
        if next_indent <= indentation:
            result[key] = None
        elif next_content.startswith("- "):
            result[key] = self._parse_sequence(next_indent)
        else:
            result[key] = self._parse_mapping(next_indent)

    def _parse_scalar(self, value: str) -> object:
        if value[0] in "[{":
            try:
                return json.loads(value, object_pairs_hook=_unique_flow_mapping)
            except json.JSONDecodeError:
                if value[0] == "[":
                    match = re.fullmatch(r"\[([^][{}]*)\]", value)
                    if match is not None:
                        items = [item.strip() for item in match.group(1).split(",")]
                        if items != [""] and all(
                            re.fullmatch(r"[A-Za-z][A-Za-z0-9_.-]*", item)
                            for item in items
                        ):
                            return items
                raise WorkflowSyntaxError(
                    f"unsupported flow collection at line {self.index}"
                ) from None
        if value[0] == '"':
            try:
                decoded = json.loads(value)
            except json.JSONDecodeError as error:
                raise WorkflowSyntaxError(
                    f"invalid double-quoted scalar at line {self.index}: {error.msg}"
                ) from None
            if not isinstance(decoded, str):
                raise WorkflowSyntaxError(
                    f"double-quoted scalar is not a string at line {self.index}"
                )
            return decoded
        if value[0] == "'":
            if len(value) < 2 or value[-1] != "'":
                raise WorkflowSyntaxError(
                    f"unterminated single-quoted scalar at line {self.index}"
                )
            return value[1:-1].replace("''", "'")
        if value[0] in "}]":
            raise WorkflowSyntaxError(
                f"malformed flow collection at line {self.index}"
            )
        return value

    def _parse_block(self, indentation: int) -> str:
        lines: list[str] = []
        block_indent: int | None = None
        while self.index < len(self.lines):
            raw = self.lines[self.index]
            if not raw.strip():
                lines.append("")
                self.index += 1
                continue
            current_indent = len(raw) - len(raw.lstrip(" "))
            if current_indent <= indentation:
                break
            if block_indent is None:
                block_indent = current_indent
            if current_indent < block_indent:
                raise WorkflowSyntaxError(
                    f"malformed block scalar at line {self.index + 1}"
                )
            lines.append(raw[block_indent:])
            self.index += 1
        return "\n".join(lines)

    def _parse_sequence(self, indentation: int) -> list[object]:
        result: list[object] = []
        while True:
            self._skip_ignored()
            if self.index >= len(self.lines):
                break
            current_indent, content = self._current()
            if current_indent < indentation:
                break
            if current_indent != indentation or not content.startswith("- "):
                raise WorkflowSyntaxError(f"malformed sequence at line {self.index + 1}")
            remainder = content[2:].strip()
            if not remainder:
                raise WorkflowSyntaxError(f"empty sequence item at line {self.index + 1}")
            item: dict[str, object] = {}
            self._parse_mapping_entry(item, indentation + 2, remainder)
            while True:
                self._skip_ignored()
                if self.index >= len(self.lines):
                    break
                next_indent, next_content = self._current()
                if next_indent != indentation + 2 or next_content.startswith("- "):
                    break
                self._parse_mapping_entry(item, indentation + 2, next_content)
            result.append(item)
        return result


def parse_workflow(
    source: str, *, label: str = "workflow"
) -> tuple[dict[str, object] | None, list[str]]:
    if YAML_ANCHOR_OR_ALIAS.search(source):
        return None, [f"{label} must not use YAML anchors or aliases"]
    try:
        return WorkflowSubsetParser(source).parse(), []
    except WorkflowSyntaxError as error:
        return None, [f"{label} has invalid structure: {error}"]


def mapping(value: object) -> dict[str, object]:
    return value if isinstance(value, dict) else {}


def steps(job: dict[str, object]) -> list[dict[str, object]]:
    value = job.get("steps")
    if not isinstance(value, list) or any(not isinstance(step, dict) for step in value):
        return []
    return value


def run_lines(job: dict[str, object]) -> list[str]:
    lines: list[str] = []
    for step in steps(job):
        run = step.get("run")
        if not isinstance(run, str):
            continue
        lines.extend(
            line.strip()
            for line in run.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    return lines


def run_bodies(job: dict[str, object]) -> list[tuple[str, ...]]:
    return [
        tuple(run_lines({"steps": [step]}))
        for step in steps(job)
        if "run" in step
    ]


def flow_list(value: object) -> set[str] | None:
    if isinstance(value, list):
        return set(value) if all(isinstance(item, str) for item in value) else None
    if not isinstance(value, str):
        return None
    match = re.fullmatch(r"\[([^]]*)\]", value)
    if match is None:
        return {value} if re.fullmatch(r"[a-z][a-z0-9-]*", value) else None
    items = [item.strip() for item in match.group(1).split(",")]
    if not all(re.fullmatch(r"[a-z][a-z0-9-]*", item) for item in items):
        return None
    return set(items)


def step_shape(step: dict[str, object]) -> dict[str, object]:
    shaped = dict(step)
    run = shaped.get("run")
    if isinstance(run, str):
        shaped["run-sha256"] = hashlib.sha256(run.encode()).hexdigest()
        del shaped["run"]
    return shaped


def job_shape(job: dict[str, object]) -> dict[str, object]:
    shaped = {key: value for key, value in job.items() if key != "steps"}
    if "steps" in job:
        shaped["steps"] = [step_shape(step) for step in steps(job)]
    return shaped


def checkout_step(ref: str) -> dict[str, object]:
    return {
        "name": "Check out exact commit",
        "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
        "with": {
            "ref": ref,
            "fetch-depth": "0",
            "persist-credentials": "false",
            "submodules": "recursive",
        },
    }


def validate_exact_workflow(
    workflow: str,
    *,
    label: str,
    expected_root: dict[str, object],
    expected_jobs: dict[str, object],
) -> list[str]:
    root, parse_errors = parse_workflow(workflow, label=label)
    if root is None:
        return parse_errors
    fields = {key: value for key, value in root.items() if key != "jobs"}
    errors: list[str] = []
    if fields != expected_root:
        errors.append(f"{label} must use its exact event, permission, and root contract")
    jobs = mapping(root.get("jobs"))
    if set(jobs) != set(expected_jobs):
        errors.append(f"{label} must use its exact job set")
    for name, expected in expected_jobs.items():
        if job_shape(mapping(jobs.get(name))) != expected:
            errors.append(f"{label} job {name} must use its exact fail-closed mapping")
    return errors
