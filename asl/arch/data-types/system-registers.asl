// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS","surface":"arch","classification":["data-types","system-registers"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS"]}
type SystemRegister of enumeration {
    SystemRegister_THREAD_PTR,
    SystemRegister_GLOBAL_PTR,
    SystemRegister_TIME,
    SystemRegister_CORE_STATE,
    SystemRegister_CORE_ID,
    SystemRegister_THREAD_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
    SystemRegister_TILE_CAPACITY,
    SystemRegister_BLOCKNUM,
    SystemRegister_BLOCKID,
    SystemRegister_CYCLE
};

type SystemRegisterAccess of enumeration {
    SystemRegisterAccess_Unknown,
    SystemRegisterAccess_ReadOnly,
    SystemRegisterAccess_WriteOnly,
    SystemRegisterAccess_ReadWrite
};

type MaintenanceOperation of enumeration {
    Maintenance_DC_IALL,
    Maintenance_DC_IVA,
    Maintenance_DC_ISW,
    Maintenance_DC_ZVA,
    Maintenance_DC_CVA,
    Maintenance_DC_CIVA,
    Maintenance_DC_CSW,
    Maintenance_DC_CISW,
    Maintenance_IC_IALL,
    Maintenance_IC_IVA,
    Maintenance_BC_IALL,
    Maintenance_BC_IVA,
    Maintenance_TLB_IV,
    Maintenance_TLB_IAV,
    Maintenance_TLB_IA,
    Maintenance_TLB_IALL
};
