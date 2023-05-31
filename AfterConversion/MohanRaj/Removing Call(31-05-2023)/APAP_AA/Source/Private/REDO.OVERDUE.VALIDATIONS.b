$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.OVERDUE.VALIDATIONS
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL        AUTO R22 CODE CONVERSION           VM TO @VM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------

    

* DESCRIPTION:
*
* This routine is attached as a PRE routine to ACTIVITY.API for LENDING-UPDATE-OVERDUE property.
* The purpose of this routine is to get the Customer name
* --------------------------------------------------------------------------------------------------------------------------
*   Date               who           Reference                       Description
**
*
*---------------------------------------------------------------------------------------------------------------------------
*
* All File INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.AA.NAB.HISTORY
*-----------------------------------------------------------------------------------------------------------------
*Main Logic of the routine
*
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Initialise the required variables
*
INITIALISE:

    AA.OD.LRF.POS = ''
    AA.OD.LRF = "L.ADJ.DATE":@VM:"L.RESTRUCT.TYPE":@VM:"L.LOAN.COND" ;*AUTO R22 CODE CONVERSION
    CALL MULTI.GET.LOC.REF('AA.PRD.DES.OVERDUE',AA.OD.LRF,AA.OD.LRF.POS)
    WPOS.DATE = AA.OD.LRF.POS<1,1>
    WPOS.TYPE = AA.OD.LRF.POS<1,2>
    WPOS.RES = AA.OD.LRF.POS<1,3>

    Y.DATE.ADJ = R.NEW(AA.OD.LOCAL.REF)<1,WPOS.DATE>
    Y.RES.TYPE = R.NEW(AA.OD.LOCAL.REF)<1,WPOS.TYPE>
    Y.RES.COND = R.NEW(AA.OD.LOCAL.REF)<1,WPOS.RES>



RETURN

*-----------------------------------------------------------------------------------------------------------------
* Trigger OFS message to update the Account Condition with Loan Status
*
PROCESS:
    IF (c_aalocActivityStatus NE 'UNAUTH') THEN
        RETURN
    END

    IF Y.DATE.ADJ GT TODAY THEN
        AF = AA.OD.LOCAL.REF
        AV = WPOS.DATE
        ETEXT = "EB-DATE.CANT.GT.THAN.TODAY"
        CALL STORE.END.ERROR
    END

    IF  Y.RES.COND EQ 'Restructured' AND NOT(Y.RES.TYPE) THEN
        AF = AA.OD.LOCAL.REF
        AV = WPOS.TYPE
        ETEXT = "EB-AA.TYPE.REST"
        CALL STORE.END.ERROR
    END


RETURN

END
