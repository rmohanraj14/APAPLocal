* @ValidationCode : MjotMzE0Nzc1MDg2OkNwMTI1MjoxNjgxODg0ODA5NDAwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 11:43:29
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
SUBROUTINE REDO.V.VAL.CANCELLATION
*------------------------------------------------------------------------------------------------------------------
* Developer    : NAVEENKUMAR.N
* Date         : 21.05.2010
* Description  : This routine will be used to check the diifferent validation on the verison
*                APAP.H.INSURANCE.DETAILS,CANCEL
*------------------------------------------------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : --N/A--
* Out : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : --N/A--
* Called By : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Version          Date          Name              Description
* -------          ----          ----              ------------
*                  26/03/2012   SANTIAGO JIJON     CHANGE VALIDATION ACCORDING BRD
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    SM TO @SM,VM TO @VM,FM TO @FM,I TO I.VAR
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.EB.LOOKUP
    $INSERT I_F.APAP.H.INSURANCE.DETAILS

    GOSUB INIT
    GOSUB CAPTURE.DATA
    GOSUB PROCESS
RETURN

*** <region name=INIT>
INIT:
*****************
    DUE.DATES = ''    ;* Holds the list of Schedule due dates
    DUE.TYPES = ''    ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''          ;* Holds the Payment Type amounts
    DUE.PROPS = ''    ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''          ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''     ;* Oustanding Bal for the date
    DUE.METHODS = ""

    SCHED.ARR = ''

    ARR.ID = R.NEW(INS.DET.ASSOCIATED.LOAN)
    ARR.DATE = R.NEW(INS.DET.INS.START.DATE)
    CYCLE.DATE = TODAY : @FM : ''
    SIM.REF = ''

    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.AA.ARRANGEMENT = ""
    R.ARR = ""
    E.ARR = ""
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.COLLATERAL = "F.COLLATERAL"
    F.COLLATERAL = ""
    R.COLLATERAL = ""
    E.COLLATERAL = ""
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.LOOKUP = "F.EB.LOOKUP"
    F.LOOKUP  = ""
    R.LOOKUP  = ""
    E.LOOKUP  = ""
    Y.LOOKUP  = "REDO.INS.CANCEL.REASON*CANCELACION.DE.PRESTAMO"
    CALL OPF(FN.LOOKUP,F.LOOKUP)

    FLAG = ''
    Y.MESSAGE = ""
    Y.OVER = ""
RETURN
*** </region>

*** <region name=PROCESS>
PROCESS:
*****************
    CALL F.READ(FN.LOOKUP,Y.LOOKUP,R.LOOKUP,F.LOOKUP,E.LOOKUP)
    IF NOT(E.LOOKUP) THEN
        Y.MESSAGE = EREPLACE(R.LOOKUP<EB.LU.DESCRIPTION><1,2>," ",".")
    END


* This field is used in the enquiries for autorization in order to distinguish the source
    R.NEW(INS.DET.INDICADOR) = PGM.VERSION

    AAR.ID = R.NEW(INS.DET.ASSOCIATED.LOAN)
    CALL F.READ(FN.AA.ARRANGEMENT,AAR.ID,R.ARR,F.AA.ARRANGEMENT,E.ARR)
    IF NOT(E.ARR) THEN
*TUS AA Changes 20161021
*    IF R.ARR<AA.ARR.ARR.STATUS> NE "MATURED" THEN
        IF R.ARR<AA.ARR.ARR.STATUS> NE "PENDING.CLOSURE" THEN
*TUS END
            IF R.NEW(INS.DET.CANCEL.REASON) EQ Y.MESSAGE THEN
                ETEXT = "EB-REDO.INS.RELATED"
                CALL STORE.END.ERROR
            END ELSE
                Y.OVER = "PRESTAMO ASOCIADO ACTIVO"
                GOSUB THROW.OVERRIDE
            END
        END
    END

    Y.TOTVM = DCOUNT(R.NEW(INS.DET.COLLATERAL.ID),@VM)
    Y.TOTSM = DCOUNT(R.NEW(INS.DET.COLLATERAL.ID),@SM)

    FOR I.VAR = 1 TO Y.TOTVM ;*R22 Auto code conversion
        FOR J.VAR = 1 TO Y.TOTSM ;*R22 Auto code conversion
            GOSUB VALIDATE.COLLATERAL
        NEXT
    NEXT


RETURN
*** </region>

*** <region name=VALIDATE.COLLATERAL>
VALIDATE.COLLATERAL:
*********************

    Y.IDCOLL = R.NEW(INS.DET.COLLATERAL.ID)<I.VAR,J.VAR> ;*R22 Auto code conversion
    CALL F.READ(FN.COLLATERAL,Y.IDCOLL,R.COLLATERAL,F.COLLATERAL,E.COLLATERAL)
    IF NOT(E.COLLATERAL) THEN
        IF (R.COLLATERAL<COLL.EXPIRY.DATE> LE TODAY) AND (R.COLLATERAL<COLL.STATUS> EQ "LIQ" OR  R.COLLATERAL<COLL.STATUS> EQ "MAT") THEN
            GOSUB CAPTURE.DATA
        END ELSE
            Y.OVER = "GARANTIA ASOCIADA ACTIVA"
            GOSUB THROW.OVERRIDE
        END
    END
RETURN
*** </region>

*** <region name=CAPTURE.DATA>
CAPTURE.DATA:
*********************

    R.NEW(INS.DET.POLICY.STATUS) = "CANCELADA"

    IF R.NEW(INS.DET.MANAGEMENT.TYPE) EQ 'INCLUIR EN CUOTA' THEN
        CALL AA.SCHEDULE.PROJECTOR(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.TYPES, DUE.DEFER.DATES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)         ;* Routine to Project complete schedules

        R.NEW(INS.DET.INS.END.DATE) = FIELD(DUE.DATES,@FM,1)
    END

RETURN
*** </region>

*** <region name=THROW.OVERRIDE>
THROW.OVERRIDE:
*********************
    CURR.NO = DCOUNT(R.NEW(INS.DET.OVERRIDE),@VM)+1
    R.NEW(INS.DET.POLICY.STATUS) = "CANCELADA"
    TEXT = "APAP.ASSOCIATED.LOAN.CANCEL": @FM : Y.OVER
    CALL STORE.OVERRIDE(CURR.NO)
*** </region>

END
