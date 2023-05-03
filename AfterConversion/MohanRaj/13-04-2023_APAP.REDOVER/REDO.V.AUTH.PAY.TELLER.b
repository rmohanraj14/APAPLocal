* @ValidationCode : MjotMTY4NzY4MjE0NTpDcDEyNTI6MTY4MTM4MTM4MjA0OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:53:02
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
SUBROUTINE REDO.V.AUTH.PAY.TELLER
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This routine will be executed at the Authorisation level for the Following
* versions of TELLER,PAYMENT.CERTIFIED.CHEQUES.This Routine will be used for paying the certified
* cheques through TELLER window and also after validating the status other than "ISSUED"
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
* ---------------------------
* IN : -NA-
* OUT : -NA-
* Linked With : TELLER
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.AUTH.PAY.TELLER
*------------------------------------------------------------------------------------------
* Modification History :
*-------------------------------------
* DATE WHO REFERENCE DESCRIPTION
* 22.03.2010 SUDHARSANAN S ODR-2009-10-0319 INITIAL CREATION
* 05.03.2012 RTAM $HIS Updations &
* TXN Completed issue
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.CERTIFIED.CHEQUE.DETAILS
    $INSERT I_F.CERTIFIED.CHEQUE.STOCK

    GOSUB INIT
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.CERTIFIED.CHEQUE.DETAILS = 'F.CERTIFIED.CHEQUE.DETAILS'
    F.CERTIFIED.CHEQUE.DETAILS = ''

    FN.CERTIFIED.CHEQUE.DETAILS$HIS = 'F.CERTIFIED.CHEQUE.DETAILS$HIS'
    F.CERTIFIED.CHEQUE.DETAILS$HIS = ''

    FN.CERTIFIED.CHEQUE.STOCK = 'F.CERTIFIED.CHEQUE.STOCK'
    F.CERTIFIED.CHEQUE.STOCK = ''

    CALL OPF(FN.CERTIFIED.CHEQUE.DETAILS,F.CERTIFIED.CHEQUE.DETAILS)
    CALL OPF(FN.CERTIFIED.CHEQUE.DETAILS$HIS,F.CERTIFIED.CHEQUE.DETAILS$HIS)

    CALL OPF(FN.CERTIFIED.CHEQUE.STOCK,F.CERTIFIED.CHEQUE.STOCK)

    LREF.APP = 'TELLER'
    LREF.FIELD = 'CERT.CHEQUE.NO'
    LREF.POS = ''
    CALL GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)

    CON.DATE = OCONV(DATE(),"D-")
    Y.DATE.TIME = CON.DATE[9,2]:CON.DATE[1,2]:CON.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]

RETURN

*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------
*Paying cheques status as changed to PAID

    Y.CERT.CHEQ.NO = R.NEW(TT.TE.LOCAL.REF)<1,LREF.POS>
    CALL F.READ(FN.CERTIFIED.CHEQUE.STOCK,Y.CERT.CHEQ.NO,R.CERT.CHEQ.STO,F.CERTIFIED.CHEQUE.STOCK,STO.ERR)
    CALL F.READ(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET,F.CERTIFIED.CHEQUE.DETAILS,DET.ERR)

    R.CERT.CHEQ.DET.HIST = R.CERT.CHEQ.DET

    IF R.NEW(TT.TE.RECORD.STATUS)[1,1] NE "R" THEN
        R.CERT.CHEQ.STO<CERT.STO.STATUS> = 'PAID'

        R.CERT.CHEQ.DET<CERT.DET.STATUS> = 'PAID'
        R.CERT.CHEQ.DET<CERT.DET.TRANS.REF> = ID.NEW
        R.CERT.CHEQ.DET<CERT.DET.COMP.CODE> = ID.COMPANY
        R.CERT.CHEQ.DET<CERT.DET.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.CURR.NO> += '1'
        R.CERT.CHEQ.DET<CERT.DET.DATE.TIME> = Y.DATE.TIME
        R.CERT.CHEQ.DET<CERT.DET.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion

    END ELSE
        R.CERT.CHEQ.STO<CERT.STO.STATUS> = 'ISSUED'

        R.CERT.CHEQ.DET<CERT.DET.STATUS> = 'ISSUED'

        R.CERT.CHEQ.DET<CERT.DET.COMP.CODE> = ID.COMPANY
        R.CERT.CHEQ.DET<CERT.DET.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.CURR.NO> += '1'
        R.CERT.CHEQ.DET<CERT.DET.DATE.TIME> = Y.DATE.TIME
        R.CERT.CHEQ.DET<CERT.DET.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion

    END
    CALL F.WRITE(FN.CERTIFIED.CHEQUE.STOCK, Y.CERT.CHEQ.NO, R.CERT.CHEQ.STO)

* CALL F.LIVE.WRITE(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET)

    CERT.CHEQ.DET.HIST.ID = Y.CERT.CHEQ.NO :';': R.CERT.CHEQ.DET.HIST<CERT.DET.CURR.NO>
    CALL F.WRITE(FN.CERTIFIED.CHEQUE.DETAILS$HIS, CERT.CHEQ.DET.HIST.ID, R.CERT.CHEQ.DET.HIST)

    CALL F.WRITE(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET)

RETURN

*------------------------------------------------------------------------------------------
END
*------------------------------------------------------------------------------------------
