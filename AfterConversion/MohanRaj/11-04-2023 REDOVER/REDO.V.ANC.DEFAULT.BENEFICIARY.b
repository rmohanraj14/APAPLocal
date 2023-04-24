* @ValidationCode : MjoxNTk0NDQzMTQ4OkNwMTI1MjoxNjgxMjE2NDA1NTcxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:03:25
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
SUBROUTINE REDO.V.ANC.DEFAULT.BENEFICIARY
*----------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Bharath G
*Program   Name    :REDO.V.ANC.DEFAULT.BENEFICIARY
*----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who             Reference            Description
* 16-APR-2010          Bharath G       PACS00055029         Initial Creation
* 09-SEP-2011          Marimuthu S     PACS00121111         Version name changed
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM, IF Condition added
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_System
    $INSERT I_F.REDO.MTS.DISBURSE
*----------------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS
RETURN
*****
INIT:
*****
*Initialize all the variables

    FN.REDO.MTS.DISBURSE = 'F.REDO.MTS.DISBURSE'
    F.REDO.MTS.DISBURSE = ''
    CALL OPF(FN.REDO.MTS.DISBURSE,F.REDO.MTS.DISBURSE)

    LREF.APP = 'FUNDS.TRANSFER'
    LREF.FIELDS = 'BENEFIC.NAME':@VM:'L.FT.CONCEPT'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    POS.BENEFIC.NAME        = LREF.POS<1,1>
    POS.CONCEPT             = LREF.POS<1,2>

RETURN
********
PROCESS:
********
* Updating acocunt id in local template

    Y.ID = System.getVariable('CURRENT.FT')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.ID = ""
    END ;*R22 Auto code conversion-END

    IF Y.ID EQ '' THEN
        RETURN
    END
    CALL F.READ(FN.REDO.MTS.DISBURSE,Y.ID,R.REDO.MTS.DISBURSE,F.REDO.MTS.DISBURSE,Y.ERR)
    IF R.REDO.MTS.DISBURSE THEN
        R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,1> = R.REDO.MTS.DISBURSE<MT.BENEFICIARY,1>
        R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,2> = R.REDO.MTS.DISBURSE<MT.BENEFICIARY,2>
        IF PGM.VERSION EQ ',CHQ.OTHERS.LOAN.DUM' THEN
            R.NEW(FT.PAYMENT.DETAILS)             = R.REDO.MTS.DISBURSE<MT.NARRATIVE>
            R.NEW(FT.LOCAL.REF)<1,POS.CONCEPT>    = R.REDO.MTS.DISBURSE<MT.REMARKS>
        END
        ELSE
            R.NEW(FT.PAYMENT.DETAILS)             = R.REDO.MTS.DISBURSE<MT.PAYMENT.DETAILS>
        END
    END

RETURN
END
