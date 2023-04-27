* @ValidationCode : MjotMzUyMDY3NTcxOkNwMTI1MjoxNjgwNzc0NDc2MTY2OkhhcmlzaHZpa3JhbUM6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:17:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.V.CUS.REL
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :RMONDRAGON
*Program   Name    :REDO.IVR.V.CUS.REL
*---------------------------------------------------------------------------------
*DESCRIPTION       :It is the validation routine to validate the ordering customer is
*                   co-holder of debit account.
*
*LINKED WITH       :
*
* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 02-DEC-2014      RMONDRAGON     ODR-2010-08-0031      Initial Creation
*
* 04-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM, ++ to +=
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT

    GOSUB INIT
    GOSUB PROCESS

RETURN

*----
INIT:
*----

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN

*-------
PROCESS:
*-------

    Y.VAR.ACC.NO = R.NEW(FT.DEBIT.ACCT.NO)
    Y.CUS.DEBIT = COMI

    IF Y.CUS.DEBIT EQ '' THEN
        RETURN
    END

    CALL F.READ(FN.ACCOUNT,Y.VAR.ACC.NO,R.ACCOUNT,F.ACCOUNT,ERR)
    IF R.ACCOUNT THEN
        GOSUB CHECK.CUS.DEBIT
    END

    IF IF.CUS.REL EQ '' THEN
        ETEXT = 'EB-REDO.CUS.NOT.RELATED'
        R.NEW(FT.ORDERING.CUST) = COMI
        CALL STORE.END.ERROR
        RETURN
    END

RETURN

*---------------
CHECK.CUS.DEBIT:
*---------------

    CUS.IDS.REL = R.ACCOUNT<AC.JOINT.HOLDER>
    IF.CUS.REL = ''

    IF CUS.IDS.REL NE '' THEN
        Y.TOT.CUS.IDS.REL = DCOUNT(CUS.IDS.REL,@VM)
        Y.CNT.CUS.IDS.REL = 1
        LOOP
        WHILE Y.CNT.CUS.IDS.REL LE Y.TOT.CUS.IDS.REL
            Y.CUS.ID  = FIELD(CUS.IDS.REL,@VM,Y.CNT.CUS.IDS.REL)
            IF Y.CUS.ID EQ Y.CUS.DEBIT THEN
                IF.CUS.REL = 'Y'
                Y.CNT.CUS.IDS.REL = Y.TOT.CUS.IDS.REL
            END
            Y.CNT.CUS.IDS.REL += 1
        REPEAT
    END

RETURN

END
