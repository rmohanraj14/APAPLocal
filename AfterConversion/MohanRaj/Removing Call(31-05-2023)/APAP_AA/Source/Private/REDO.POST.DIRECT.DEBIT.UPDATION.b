* @ValidationCode : MjoxNTI2Njc3MTM6Q3AxMjUyOjE2ODU1MzE0MDcyMzk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:40:07
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
$PACKAGE APAP.AA
SUBROUTINE REDO.POST.DIRECT.DEBIT.UPDATION
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL        AUTO R22 CODE CONVERSION          VM TO @VM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------

    
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is the Post routine for LENDING-ISSUEBILL-PAYMENT.SCHEDULE activity
* It updates the AA ID to the local table REDO.W.DIRECT.DEBIT
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who           Reference            Description
* 31-10-2011       JEEVA T        B.9-DIRECT DEBIT
*-----------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.REDO.W.DIRECT.DEBIT
    $INSERT I_F.AA.PAYMENT.SCHEDULE

    GOSUB OPEN.FILE
    GOSUB GET.ARR.CONDITION
    GOSUB PROCESS.FILE

RETURN

*-----------------------------------------------------------------------------
OPEN.FILE:
*-----------------------------------------------------------------------------
    FN.REDO.W.DIRECT.DEBIT = 'F.REDO.W.DIRECT.DEBIT'
    F.REDO.W.DIRECT.DEBIT = ''

    CALL OPF(FN.REDO.W.DIRECT.DEBIT,F.REDO.W.DIRECT.DEBIT)

    R.REDO.W.DIRECT.DEBIT = ''
    Y.ID = 'TODAY'
    CALL F.READ(FN.REDO.W.DIRECT.DEBIT,Y.ID,R.REDO.W.DIRECT.DEBIT,F.REDO.W.DIRECT.DEBIT,Y.ERR)

    Y.ARR.ID  =  c_aalocArrId

    LREF.APP = 'AA.PRD.DES.PAYMENT.SCHEDULE'
    LREF.FIELDS = 'L.AA.PAY.METHD':@VM:'L.AA.DEBT.AC' ;*AUTO R22 CODE CONVERSION
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)

    PAYMT.METHOD.POS =LREF.POS<1,1>
    DEBIT.ACCT.POS = LREF.POS<1,2>

RETURN

*-----------------------------------------------------------------------------
GET.ARR.CONDITION:
*-----------------
* Get the Interest rate properties of the particular arrangemnet
*
    Y.ARRG.ID = Y.ARR.ID
    PROPERTY.CLASS = 'PAYMENT.SCHEDULE'
    PROPERTY = ''
    EFF.DATE = ''
    ERR.MSG = ''
    R.INT.ARR.COND = ''
    APAP.AA.redoCrrGetConditions(Y.ARRG.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.PAY.ARR.COND,ERR.MSG);* R22 Manual conversion

    IF R.PAY.ARR.COND NE '' THEN
        Y.PAY.METHOD      = R.PAY.ARR.COND<AA.PS.LOCAL.REF><1,PAYMT.METHOD.POS>
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS.FILE:
*-----------------------------------------------------------------------------

    IF Y.ARR.ID AND Y.PAY.METHOD EQ 'Direct Debit' THEN
        LOCATE Y.ARR.ID IN R.REDO.W.DIRECT.DEBIT<REDO.AA.DD.ARR.ID,1> SETTING POS ELSE
            R.REDO.W.DIRECT.DEBIT<REDO.AA.DD.ARR.ID,-1> = Y.ARR.ID
            CALL F.WRITE(FN.REDO.W.DIRECT.DEBIT,Y.ID,R.REDO.W.DIRECT.DEBIT)
        END
    END

RETURN
END
