// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-SYS","surface":"scalar","classification":["model","dispatch","sys"],"depends_on":["PTO-ARCH-STATE-CORE-SYNCHRONIZATION","PTO-SCALAR-ACRC","PTO-SCALAR-ACRE","PTO-SCALAR-ASSERT","PTO-SCALAR-BC-IALL","PTO-SCALAR-BC-IVA","PTO-SCALAR-BSE","PTO-SCALAR-BWE","PTO-SCALAR-BWI","PTO-SCALAR-BWT","PTO-SCALAR-C-EBREAK","PTO-SCALAR-C-SSRGET","PTO-SCALAR-DC-CISW","PTO-SCALAR-DC-CIVA","PTO-SCALAR-DC-CSW","PTO-SCALAR-DC-CVA","PTO-SCALAR-DC-IALL","PTO-SCALAR-DC-ISW","PTO-SCALAR-DC-IVA","PTO-SCALAR-DC-ZVA","PTO-SCALAR-EBREAK","PTO-SCALAR-FENCE-D","PTO-SCALAR-FENCE-I","PTO-SCALAR-HL-SSRGET","PTO-SCALAR-HL-SSRSET","PTO-SCALAR-IC-IALL","PTO-SCALAR-IC-IVA","PTO-SCALAR-LSRGET","PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-SCALAR-SETC-TGT","PTO-SCALAR-SSRGET","PTO-SCALAR-SSRSET","PTO-SCALAR-SSRSWAP","PTO-SCALAR-SYNC-CORE","PTO-SCALAR-TLB-IA","PTO-SCALAR-TLB-IALL","PTO-SCALAR-TLB-IAV","PTO-SCALAR-TLB-IV","PTO-ARCH-STATE-MESSAGE-BUFFER","PTO-ARCH-STATE-HSCB-DISPATCH","PTO-ARCH-STATE-MESSAGE-BUFFER-SEND"]}
func ExecuteDecodedSYSForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_ACRC =>
            ArchitectureCloseRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RST_Type));
        when ScalarOperation_ACRE =>
            ArchitectureEnterRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RRA_Type));
        when ScalarOperation_ASSERT =>
            ArchitectureAssert(ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));

        when ScalarOperation_BC_IALL =>
            ExecuteMaintenance(Maintenance_BC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_BC_IVA =>
            ExecuteMaintenance(Maintenance_BC_IVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_IALL =>
            ExecuteMaintenance(Maintenance_DC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_DC_IVA =>
            ExecuteMaintenance(Maintenance_DC_IVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ISW =>
            ExecuteMaintenance(Maintenance_DC_ISW, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ZVA =>
            ExecuteMaintenance(Maintenance_DC_ZVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CVA =>
            ExecuteMaintenance(Maintenance_DC_CVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CIVA =>
            ExecuteMaintenance(Maintenance_DC_CIVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CSW =>
            ExecuteMaintenance(Maintenance_DC_CSW, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CISW =>
            ExecuteMaintenance(Maintenance_DC_CISW, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_IC_IALL =>
            ExecuteMaintenance(Maintenance_IC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_IC_IVA =>
            ExecuteMaintenance(Maintenance_IC_IVA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IV =>
            ExecuteMaintenance(Maintenance_TLB_IV, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IAV =>
            ExecuteMaintenance(Maintenance_TLB_IAV, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IA =>
            ExecuteMaintenance(Maintenance_TLB_IA, ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IALL =>
            ExecuteMaintenance(Maintenance_TLB_IALL, Zeros{PTO_XLEN});

        when ScalarOperation_BSE =>
            if MessageBufferEnabledForCurrentContext() then
                ExecuteMessageBufferSend(ReadDecodedReg5(
                    instruction, form, ScalarField_SrcL));
            else
                ExecuteControlRequest(ExecutionControl_SendEvent,
                    ReadDecodedReg5(instruction, form, ScalarField_SrcL));
            end;
        when ScalarOperation_BWE =>
            ExecuteControlRequest(ExecutionControl_WaitEvent,
                ReadDecodedReg5(instruction, form, ScalarField_SrcL));
            // The enabled platform observes the issuing worker at publication;
            // its eligibility never delays architectural BWE retirement.
            HSCBObserveWaitEvent();
        when ScalarOperation_BWI =>
            ExecuteControlRequest(ExecutionControl_WaitInterrupt,
                ReadDecodedReg5(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWT =>
            ExecuteControlRequest(ExecutionControl_WaitTimeout,
                ReadDecodedReg5(instruction, form, ScalarField_SrcL));

        when ScalarOperation_C_EBREAK =>
            SoftwareBreakpoint(ScalarDecodedBits5(
                instruction, form, ScalarField_imm5));
        when ScalarOperation_EBREAK =>
            SoftwareBreakpoint(ZeroExtend{5}(ScalarDecodedBits4(
                instruction, form, ScalarField_imm4)));
        when ScalarOperation_FENCE_D =>
            FenceData(
                ScalarDecodedBits4(instruction, form, ScalarField_PRED_IMM),
                ScalarDecodedBits4(instruction, form, ScalarField_SUCC_IMM));
        when ScalarOperation_FENCE_I => FenceInstruction();
        when ScalarOperation_SYNC_CORE => ExecuteSyncCore();

        when ScalarOperation_C_SSRGET =>
            ExecuteCompressedSystemRegisterGet(
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSRID));
        when ScalarOperation_HL_SSRGET =>
            ExecuteSystemRegisterGet(
                DecodeReg5(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_HL_SSRSET =>
            ExecuteSystemRegisterSet(
                DecodeReg5(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_LSRGET =>
            ExecuteLocalStateRegisterGet(
                DecodeReg5(instruction, form, ScalarField_RegDst),
                DecodeScalarOperandRaw(
                    instruction, form, ScalarField_LSR_ID)[11:0]);
        when ScalarOperation_SSRGET =>
            ExecuteSystemRegisterGet(
                DecodeReg5(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSET =>
            ExecuteSystemRegisterSet(
                DecodeReg5(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSWAP =>
            ExecuteSystemRegisterSwap(
                DecodeReg5(instruction, form, ScalarField_RegDst),
                DecodeReg5(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SETC_TGT =>
            SetCommitTarget(ReadDecodedReg5(
                instruction, form, ScalarField_SrcL));
        otherwise => unreachable;
    end;
end;
