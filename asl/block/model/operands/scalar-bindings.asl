// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","surface":"block","classification":["model","operands","scalar-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS"]}
func SetBundleArgument(value: Word)
begin
    _BundleArgument = value;
    _BundleArgumentKind = '001';
    _CommitArgument = value;
end;

func SetBundleArgumentKind(kind: bits(3), value: Word)
begin
    _BundleArgumentKind = kind;
    _BundleArgument = value;
    _CommitArgument = value;
end;

func SetBundleBodyAddress(address: Word)
begin
    if address[0] == '1' then
        SetFault(Fault_InstructionPC, address);
    else
        _BundleBodyAddress = address;
        WriteBPC(address);
    end;
end;

func SetBundleScalarBinding(index: BundleScalarBindingIndex,
                           destination: Reg5Selector,
                           source0: Reg5Selector,
                           source1: Reg5Selector,
                           source2: Reg5Selector,
                           source_count: integer {0..3})
begin
    _BundleScalarBindings[[index]].valid = TRUE;
    _BundleScalarBindings[[index]].destination = destination;
    _BundleScalarBindings[[index]].source0 = source0;
    _BundleScalarBindings[[index]].source1 = source1;
    _BundleScalarBindings[[index]].source2 = source2;
    _BundleScalarBindings[[index]].source_count = source_count;
end;

