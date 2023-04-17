* @ValidationCode : Mjo5NTMyMDY0NjQ6Q3AxMjUyOjE2ODE3MjczNzEyMzQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 15:59:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.INP.CUS.PROV.CHECK

*--------------------------------------------------------------------------------
*Company   Name    : Asociacion Popular de Ahorros y Prestamos
*Developed By      : JEEVA T
*Program   Name    : REDO.V.INP.CUS.PROV.CHECK
*HD Issue No       : PACS00086351
*---------------------------------------------------------------------------------

*DESCRIPTION       : this is check the porvision value
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.H.PROVISION.PARAMETER

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*------------------------------------------------------------------------------
*DESCRIPTION : Initialising the variables
*------------------------------------------------------------------------------
INIT:

    LOC.REF.APPLICATION="CUSTOMER"
    LOC.REF.FIELDS='L.CU.PRO.RATING'
    LOC.REF.POS=''
    Y.VAL = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    LOC.PROV.POS = LOC.REF.POS<1,1>
RETURN

*------------------------------------------------------------------------------
*DESCRIPTION: Opening the files ACCOUNT, FT.COMMISSION.TYPE and ACCOUNT.CLOSURE
*------------------------------------------------------------------------------
OPEN.FILES:

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    FN.REDO.H.PROVISION.PARAMETER ='F.REDO.H.PROVISION.PARAMETER'
    F.REDO.H.PROVISION.PARAMETER = ''
    CALL OPF(FN.REDO.H.PROVISION.PARAMETER,F.REDO.H.PROVISION.PARAMETER)

RETURN

*--------------------------------------------------------------------------------
*DESCRIPTION:
*--------------------------------------------------------------------------------
PROCESS:

    Y.VAL = R.NEW(EB.CUS.LOCAL.REF)<1,LOC.PROV.POS>
    IF Y.VAL THEN
        CALL CACHE.READ(FN.REDO.H.PROVISION.PARAMETER,'SYSTEM',R.REDO.H.PROVISION.PARAMETER,Y.ERR)
        Y.CALSS = R.REDO.H.PROVISION.PARAMETER<PROV.RATING.TYPE>
        CHANGE @SM TO @FM IN Y.CALSS
        CHANGE @VM TO @FM IN Y.CALSS
        LOCATE Y.VAL IN Y.CALSS SETTING POS ELSE
            AF = EB.CUS.LOCAL.REF
            AV = LOC.PROV.POS
            ETEXT = 'EB-CUS.PROV.NOT.PARA'
            CALL STORE.END.ERROR
        END
    END
RETURN
END
