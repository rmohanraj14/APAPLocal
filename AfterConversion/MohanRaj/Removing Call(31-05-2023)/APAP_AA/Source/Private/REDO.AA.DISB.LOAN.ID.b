$PACKAGE APAP.AA ;* R22 Manual Code Conversion
SUBROUTINE REDO.AA.DISB.LOAN.ID
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*  This routine is .ID routine to
*
*
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*-----------------------------------------------------------------------------
*   Date               who           Reference            Description
* 04-28-2011          Bharath G         N.45              INITIAL CREATION
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023      Conversion Tool                      R22 Auto Code Conversion             Nochange
* ----------------------------------------------------------------------------

*-----------------------------------------------------------------------------------

    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.AA.DISB.LOAN
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM
 
    FN.REDO.AA.DISB.LOAN = 'F.REDO.AA.DISB.LOAN'
    F.REDO.AA.DISB.LOAN = ''
    R.REDO.AA.DISB.LOAN = ''
    CALL OPF(FN.REDO.AA.DISB.LOAN,F.REDO.AA.DISB.LOAN)

    IF  V$FUNCTION EQ 'I' THEN
        CALL F.READ(FN.REDO.AA.DISB.LOAN,COMI,R.REDO.AA.DISB.LOAN,F.REDO.AA.DISB.LOAN,DISB.LN.ERR)
        LOAN.DISB.REF = ''
        LOAN.DISB.REF = R.REDO.AA.DISB.LOAN<DISB.LN.MN.DISB.REF>
        IF LOAN.DISB.REF NE '' THEN
            E = 'EB-FT.GENERATE.NO.EDIT'
        END
    END

RETURN
*-----------------------------------------------------------------------------
END
