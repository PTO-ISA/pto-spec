import {Prism} from 'prism-react-renderer';

let registered = false;

export function registerAslPrism(): void {
  if (registered && Prism.languages.asl !== undefined) return;
  Prism.languages.asl = {
    comment: /\/\/.*$/m,
    string: {
      pattern: /'(?:\\.|[^'\\\r\n])*'|"(?:\\.|[^"\\\r\n])*"/,
      greedy: true,
    },
    keyword: /\b(?:array|as|assert|begin|bits|case|catch|config|constant|do|downto|else|elsif|end|enum|enumeration|for|func|if|impdef|in|integer|let|looplimit|of|otherwise|pure|readonly|real|record|repeat|return|then|throw|to|try|type|typeof|until|var|when|where|while)\b/,
    boolean: /\b(?:TRUE|FALSE)\b/,
    number: /\b(?:0[xX][\dA-Fa-f](?:_?[\dA-Fa-f])*|0[bB][01](?:_?[01])*|\d(?:_?\d)*)\b/,
    builtin: /\b(?:Zeros|Ones|UInt|SInt|ZeroExtend|SignExtend|LSL|LSR|ASR|ROR)\b/,
    function: /\b[A-Za-z_][A-Za-z\d_]*(?=\s*(?:\{|\())/,
    operator: /=>|==|!=|<=|>=|&&|\|\||<<|>>|::|[-+*/%&|^~!<>=]/,
    punctuation: /[{}[\];(),.:]/,
  };
  registered = true;
}

registerAslPrism();
