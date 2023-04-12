* @ValidationCode : MjoxMjM0OTk5MDAzOkNwMTI1MjoxNjgxMjg2OTg4NDQyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:39:48
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
SUBROUTINE REDO.V.AUT.REINS.STATUS
*-----------------------------------------------------------------------------
* Developer   : TAM
* Date        : 14.05.2010
* Description : AUTH ROUTINE FOR VERSIONS AS FOLLOWS
* TELLER      : REDO.REINSTATE
*----------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : --N/A--
* Out : --N/A--
*----------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : --N/A--
* Called By : --N/A--
*----------------------------------------------------------------------------
* Revision History:
* -----------------
* Date          Name                                Reference                      Description
* -------       ----                                ---------                      ------------
* 7-04-2013  VIGNESH A.S/Mohammed Anies K         ODR-2010-03-0447              Initial creation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion    TNO:"_":OPERATOR TO C$T24.SESSION.NO:"_":OPERATOR ,VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.USER
    $INSERT I_F.TELLER
*
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.ADMIN.CHQ.DETAILS
*
    GOSUB INITIALIZE
    GOSUB PROCESS
*
RETURN
*
***********
INITIALIZE:
***********
    Y.CHEQUE.NUMBER = R.NEW(TT.TE.CHEQUE.NUMBER)

    FN.REDO.H.ADMIN.CHEQUES= "F.REDO.H.ADMIN.CHEQUES"
    F.REDO.H.ADMIN.CHEQUES= ""
    R.REDO.H.ADMIN.CHEQUES= ''

    FN.REDO.ADMIN.CHQ.DETAILS= "F.REDO.ADMIN.CHQ.DETAILS"
    F.REDO.ADMIN.CHQ.DETAILS= ""
    R.REDO.ADMIN.CHQ.DETAILS= ''

    CALL OPF(FN.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES)
    CALL OPF(FN.REDO.ADMIN.CHQ.DETAILS,F.REDO.ADMIN.CHQ.DETAILS)

    DIM R.MAT.CHQ.REC(REDO.ADMIN.AUDIT.DATE.TIME)
    DIM R.MAT.DET.REC(ADMIN.CHQ.DET.AUDIT.DATE.TIME)
*
RETURN
*
********
PROCESS:
********
*
    IF Y.CHEQUE.NUMBER THEN
        GOSUB UPDATE.CHQ.DETAILS
    END
*
RETURN
*
*******************
UPDATE.CHQ.DETAILS:
*******************
*
    CALL F.READ(FN.REDO.ADMIN.CHQ.DETAILS,Y.CHEQUE.NUMBER,R.REDO.ADMIN.CHQ.DETAILS,F.REDO.ADMIN.CHQ.DETAILS,Y.ERR.REDO.ADMIN.CHQ.DETAILS)
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.STATUS>="REINSTATED"
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.REINSTATED.DATE>=TODAY
*
    GOSUB UPDATE.AUDIT.CHEQUE.DETAILS
*
    MATPARSE R.MAT.DET.REC FROM R.REDO.ADMIN.CHQ.DETAILS
    CALL EB.HIST.REC.WRITE(FN.REDO.ADMIN.CHQ.DETAILS,Y.CHEQUE.NUMBER,MAT R.MAT.DET.REC,ADMIN.CHQ.DET.AUDIT.DATE.TIME)
*
*Now update the Other Table REDO.H.ADMIN.CHEQUES
*
    REDO.H.ADMIN.CHEQUES.ID = R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.CHQ.SEQ.NUM>
    CALL F.READ(FN.REDO.H.ADMIN.CHEQUES, REDO.H.ADMIN.CHEQUES.ID, R.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES,Y.ERR.REDO.H.ADMIN.CHEQUES)
    IF R.REDO.H.ADMIN.CHEQUES THEN
        R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.STATUS> = "REINSTATED"
    END
*
    GOSUB UPDATE.AUDIT.ADMIN.CHEQUE
*
    MATPARSE R.MAT.CHQ.REC FROM R.REDO.H.ADMIN.CHEQUES
    CALL EB.HIST.REC.WRITE(FN.REDO.H.ADMIN.CHEQUES, REDO.H.ADMIN.CHEQUES.ID, MAT R.MAT.CHQ.REC,REDO.ADMIN.AUDIT.DATE.TIME)
*
RETURN
*
****************************
UPDATE.AUDIT.CHEQUE.DETAILS:
****************************
* To update Audit fields
*
    Y.INPUTTER.CHQ   = DCOUNT(R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.INPUTTER>,@VM)
    Y.DATE.TIME.CHQ  = DCOUNT(R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.DATE.TIME>,@VM)
    GOSUB TIME.MANU
*
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.CURR.NO>                   = R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.CURR.NO> + 1
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.INPUTTER,Y.INPUTTER.CHQ>   = C$T24.SESSION.NO:"_":OPERATOR ;*R22 Auto code conversion
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.AUTHORISER,Y.INPUTTER.CHQ> = C$T24.SESSION.NO:"_":OPERATOR ;*R22 Auto code conversion
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.CO.CODE>                   = ID.COMPANY
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.DEPT.CODE>                 = R.USER<EB.USE.DEPARTMENT.CODE>
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.RECORD.STATUS>             = ""
    R.REDO.ADMIN.CHQ.DETAILS<ADMIN.CHQ.DET.DATE.TIME,Y.DATE.TIME.CHQ> = DATE.TIME
*
RETURN
*
**************************
UPDATE.AUDIT.ADMIN.CHEQUE:
**************************
* To update Audit fields
*
    Y.INPUTTER.CHEQUE    = DCOUNT(R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.INPUTTER>,@VM)
    Y.DATE.TIME.CHEQUE   = DCOUNT(R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.DATE.TIME>,@VM)
    GOSUB TIME.MANU
*
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CURR.NO>                      = R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CURR.NO> + 1
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.INPUTTER,Y.INPUTTER.CHEQUE>   = C$T24.SESSION.NO:"_":OPERATOR ;*R22 Auto code conversion
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.AUTHORISER,Y.INPUTTER.CHEQUE> = C$T24.SESSION.NO:"_":OPERATOR ;*R22 Auto code conversion
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CO.CODE>                      = ID.COMPANY
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.DEPT.CODE>                    = R.USER<EB.USE.DEPARTMENT.CODE>
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.RECORD.STATUS>                = ""
    R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.DATE.TIME,Y.DATE.TIME.CHEQUE> = DATE.TIME
*
RETURN
*
**********
TIME.MANU:
**********
* To update date and time
    CON.DATE  = OCONV(DATE(),"D-")
    DATE.TIME = CON.DATE[9,2]:CON.DATE[1,2]:CON.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
*
RETURN
*
END
