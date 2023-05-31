* @ValidationCode : MjotMTE3OTA1MjE2NzpDcDEyNTI6MTY4NTUzMTQ1NTI0NTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:40:55
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
$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.POST.MORTGAGE.STATUS
*-----------------------------------------------------------------------------

*DESCRIPTION:
*------------
* This Routine used as the Post Routine for the activity LENDING-UPDATE-OVERDUE
* Loan Status will be updated to local table REDO.APAP.MORTGAGES.DETAIL.
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
* Date          Who            Reference         Description
* 16-AUG-2011   Pradeep S      PACS00101742      Initial Creation
*------------------------------------------------------------------------------------------------------
*Modification History:
*Date           Who                     Reference                                  Descripition
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA, CALL method format changed
* 29-03-2023    Conversion Tool     Auto R22 code conversion                     VM TO @VM, SM TO @SM
*--------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.APAP.MORTGAGES.DETAIL
    $USING APAP.TAM
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB PRELIM.CONDITIONS
    IF PROCESS.GOHEAD THEN
        GOSUB PROCESS
    END

RETURN


PROCESS:
*********

    BEGIN CASE
        CASE c_aalocActivityStatus EQ 'AUTH'
            GOSUB UPDATE.MORTGAGE.DETAILS

        CASE c_aalocActivityStatus EQ 'AUTH-REV'
            GOSUB REVERSE.MORTGAGE.DETAILS
    END CASE

RETURN

UPDATE.MORTGAGE.DETAILS:
**************************
    GOSUB READ.MORTGAGE.DETAIL
    IF R.MG.DTL THEN
        R.MG.DTL<MG.DET.STATUS> = Y.LOAN.STATUS
        GOSUB WRITE.MORTGAGE.DETAIL
    END

RETURN

REVERSE.MORTGAGE.DETAILS:
***************************

    Y.LOAN.STATUS.CNT = DCOUNT(Y.LOAN.STATUS,@VM) ;*AUTO R22 CODE CONVERSION
    Y.CNT = 1
    GOSUB READ.MORTGAGE.DETAIL
    IF R.MG.DTL THEN
        LOOP
        WHILE Y.CNT LE Y.LOAN.STATUS.CNT
            LOCATE Y.LOAN.STATUS<1,Y.CNT> IN R.MG.DTL<MG.DET.STATUS,1> SETTING LOAN.POS THEN
                DEL R.MG.DTL<MG.DET.STATUS,LOAN.POS>
            END
            Y.CNT += 1
        REPEAT
        GOSUB WRITE.MORTGAGE.DETAIL
    END

RETURN

READ.MORTGAGE.DETAIL:
**********************
    Y.MG.DTL.ID = OUT.ID
    R.MG.DTL = ''
    CALL F.READ(FN.REDO.APAP.MORTGAGES.DETAIL,Y.MG.DTL.ID,R.MG.DTL,F.REDO.APAP.MORTGAGES.DETAIL,ERR.DTL)

RETURN

WRITE.MORTGAGE.DETAIL:
***********************

    CALL F.WRITE(FN.REDO.APAP.MORTGAGES.DETAIL,Y.MG.DTL.ID,R.MG.DTL)

RETURN

INIT:
******

    FN.REDO.APAP.MORTGAGES.DETAIL = 'F.REDO.APAP.MORTGAGES.DETAIL'
    F.REDO.APAP.MORTGAGES.DETAIL = ''
    CALL OPF(FN.REDO.APAP.MORTGAGES.DETAIL,F.REDO.APAP.MORTGAGES.DETAIL)

    LOC.REF.APPL = "AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS = "L.LOAN.STATUS.1"
    Y.LOAN.STATUS.POS = " "
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,Y.LOAN.STATUS.POS)
    Y.LOAN.STATUS = R.NEW(AA.OD.LOCAL.REF)<1,Y.LOAN.STATUS.POS>
    CHANGE @SM TO @VM IN Y.LOAN.STATUS ;*AUTO R22 CODE CONVERSION

RETURN

PRELIM.CONDITIONS:
********************

    PROCESS.GOHEAD = @TRUE

    IN.ACC.ID = ''
    IN.ARR.ID = c_aalocArrId
    OUT.ID = ''
    ERR.TEXT = ''

    APAP.TAM.redoConvertAccount(IN.ACC.ID,IN.ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion

    IF ERR.TEXT THEN
        PROCESS.GOHEAD = @FALSE
    END

RETURN

END
