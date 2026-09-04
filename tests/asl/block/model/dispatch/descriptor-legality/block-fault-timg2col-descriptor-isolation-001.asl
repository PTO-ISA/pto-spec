// PTO-TEST: {"id":"PTO-AVS-BLOCK-TIMG2COL-DESCRIPTOR-ISOLATION-001","source":"asl/block/model/dispatch/descriptor-legality.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-BSTART-TIMG2COL-CONTRACT-001"],"kind":"fault","summary":"Only the exact command-only TileMemory descriptor owns TIMG2COL Function 28.","pass_condition":"The canonical descriptor is legal while a wrong class, selector, DataType, or form identity rejects.","related_sources":["asl/block/execution/BSTART.TIMG2COL.asl"]}
func main() => integer
begin
    ResetProfileState();
    var descriptor = BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7} + 94,
        operation_class = BundleOperation_TileMemory,
        selector_valid = TRUE,
        selector = Zeros{10} + 28,
        data_type_valid = TRUE,
        data_type = Zeros{5} + 27,
        mode_valid = FALSE,
        mode = Zeros{2},
        branch_type_valid = FALSE,
        branch_type = Zeros{3}
    };
    assert BundleOperationDescriptorLegal(descriptor);
    descriptor.operation_class = BundleOperation_Control;
    assert !BundleOperationDescriptorLegal(descriptor);
    descriptor.operation_class = BundleOperation_TileMemory;
    descriptor.selector = Zeros{10} + 27;
    assert !BundleOperationDescriptorLegal(descriptor);
    descriptor.selector = Zeros{10} + 28;
    descriptor.data_type = Zeros{5};
    assert !BundleOperationDescriptorLegal(descriptor);
    descriptor.data_type = Zeros{5} + 27;
    descriptor.form_identity = Zeros{7} + 76;
    assert !BundleOperationDescriptorLegal(descriptor);
    return 0;
end;
