$PACKAGE APAP.AA  ;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.V.VAL.BAL.UPDATE
    
*-----------------------------------------------------------------------------------
* Modification History:
*
*DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023         SURESH          MANUAL R22 CODE CONVERSTION     Package Name added APAP.AA
* 29/03/2023         Conversion Tool          AUTO R22 CODE CONVERSTION           NOCHANGE
*-----------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------------------
* Developer    : NAVEENKUMAR.N
* Date         : 26.05.2010
* Description  : REDO.V.VAL.BAL.UPDATE
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
* Version        Date            Name              Description
* -------        ----            ----              ------------
*   1.0        26.05.2010      NAVEENKUMAR.N       Initial Creation
*   2.0        04.09.2010      Ramkumar G      Added some more validation as a port of B2-CR (ODR-2010-09-0011)
*------------------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_REDO.T.AUTH.POST.COMMON
    $INSERT I_F.REDO.T.AUTH.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON

    IF V$FUNCTION EQ 'A' THEN
        GOSUB UPDATE.TABLE
    END
RETURN

UPDATE.TABLE:

    FN.REDO.T.AUTH.ARRANGEMENT = "F.REDO.T.AUTH.ARRANGEMENT"
    F.REDO.T.AUTH.ARRANGEMENT = ""
    R.REDO.T.AUTH.ARRANGEMENT = ""
    CALL OPF(FN.REDO.T.AUTH.ARRANGEMENT,F.REDO.T.AUTH.ARRANGEMENT)

    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.FHA.CASE.NUMBER> = Y.CASE.NO
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POLICY.NUMBER>   =  POL.NUMBER
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.SEN.POLICY.NO> = SEN.POL.NUMBER
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.POLICY.TYPE> = INS.POL.TYPE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.CLASS.POLICY> = CLASS.POLICY
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.FHA.CASE.NUMBER> = Y.CASE.NO
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.MANAGEMENT.TYPE> = MGMT.TYPE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.COMPANY> = INS.COMP
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.AMOUNT> = INS.AMOUNT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.AMOUNT.DATE> = INS.AMT.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.MON.POL.AMT> = MON.POL.AMT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.MON.POL.AMT.DAT> = MON.POL.AMT.DAT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.EXTRA.AMT> = EXTRA.AMT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.MON.TOT.PRE.AMT> = MON.TOT.PRE.AMT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.TOT.PREM.AMT> = TOT.PREMIUM.AMT
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POLICY.ORG.DATE> = POLICY.ORG.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POL.START.DATE> = POL.START.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POL.EXP.DATE> = POL.EXP.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.REMARKS> = REMARKS
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POL.STATUS> = POL.STATUS
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.COLLATERAL.ID> = COLL.ID
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.CTRL.APP.DAT> = CU.APP.CTRL.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.INS.CTRL.RC.DAT> = CU.REC.CTRL.DATE
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POLICY.STATUS> = POLICY.STATUS
    R.REDO.T.AUTH.ARRANGEMENT<REDO.ARR.POL.ISSUE.DATE> = POL.ISSUE.DATE
    Y.ARR.ID=c_aalocArrId
    CALL F.WRITE(FN.REDO.T.AUTH.ARRANGEMENT,Y.ARR.ID,R.REDO.T.AUTH.ARRANGEMENT)

RETURN
