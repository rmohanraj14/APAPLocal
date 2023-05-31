* @ValidationCode : Mjo1NjAxNDA4Mjk6Q3AxMjUyOjE2ODAxODQ2NzM2MjA6SVRTUzotMTotMTo1MDA6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 500
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.MARK.AA.CREATED
*-----------------------------------------------------------------------------
* This routine is used to mark whether Arrangment ID is created or not.
*-----------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 24-01-2013        S.MARIMUTHU     PACS00238973        Initial Creation
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY


    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    CALL OPF(FN.AA.ARR,F.AA.ARR)

    FN.RCA = 'F.REDO.CREATE.ARRANGEMENT'
    F.RCA = ''
    CALL OPF(FN.RCA,F.RCA)

    APLN = 'AA.ARRANGEMENT.ACTIVITY'
    F.FIELDSS =  'TXN.REF.ID'
    Y.POS = ''
    CALL MULTI.GET.LOC.REF(APLN,F.FIELDSS,Y.POS)
    Y.TXN.POS = Y.POS<1,1>

    Y.RCA.ID = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,Y.TXN.POS>

    Y.AA.ID = R.NEW(AA.ARR.ACT.ARRANGEMENT)

    CALL F.READ(FN.AA.ARR,Y.AA.ID,R.AA.ARR,F.AA.ARR,AA.ARR.ERR)
    IF R.AA.ARR THEN
        R.RCA = ''
        CALL F.READ(FN.RCA,Y.RCA.ID,R.RCA,F.RCA,RCA.ERR)
        R.RCA<REDO.FC.CHK.AA.ID> = 'Y'
        CALL F.WRITE(FN.RCA,Y.RCA.ID,R.RCA)
    END

RETURN

END
