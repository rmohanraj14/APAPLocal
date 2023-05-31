$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.POST.ARRANGEMENT.REVERSAL
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL        AUTO R22 CODE CONVERSION           NO CHANGES
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------

    
*-----------------------------------------------------
*Description: This post routine will get triggered during the Auth-rev stage
*             of the lending new arrangement activity to remove the arrangement id
*             from the account application. so that we can close the account using
*             account closure application.
*-----------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT

    IF c_aalocActivityStatus EQ "AUTH-REV" THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------
PROCESS:
*-----------------------------------------------------
    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT  = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.ACC.ID = c_aalocLinkedAccount
    CALL F.READ(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    IF R.ACCOUNT<AC.ARRANGEMENT.ID> THEN
        R.ACCOUNT<AC.ARRANGEMENT.ID> = ""
        TEMP.V=V
        V=AC.AUDIT.DATE.TIME
        CALL F.LIVE.WRITE(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT)
        V=TEMP.V
    END

RETURN
END
