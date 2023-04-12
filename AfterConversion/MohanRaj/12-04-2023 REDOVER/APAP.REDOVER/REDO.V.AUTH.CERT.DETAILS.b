* @ValidationCode : MjotNzcxMzMyNDg6Q3AxMjUyOjE2ODEzMDI1NjUzMjU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:59:25
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
SUBROUTINE REDO.V.AUTH.CERT.DETAILS
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This routine will be executed at Authorisation Level for the Following versions of
* TELLER,CHEQUE.GOVERNMENT.TAX and TELLER,CHEQUE.GOVERNMENT.BENEFICIARY. This Routine is used
* to update all the Cheque Informations in the Local tables CERTIFIED.CHEQUE.STOCK and CERTIFIED.CHEQUE.DETAILS
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
* Linked : TELLER
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.AUTH.CERT.DETAILS
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*
*    DATE           WHO               REFERENCE         DESCRIPTION
*    16.03.2010     SUDHARSANAN S     ODR-2009-10-0319  INITIAL CREATION
*    23.FEB.2012    J.COSTA C.        PACS00172914      PRUEBAS DE GRUPOS
*    05.MAR.2012                                        Updation to $HIS file &
*                                                       Chq duplication.
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR,VM TO @VM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
*
    $INSERT I_F.TELLER
*
    $INSERT I_F.CERTIFIED.CHEQUE.STOCK
    $INSERT I_F.CERTIFIED.CHEQUE.DETAILS
*

    GOSUB INIT
    GOSUB PROCESS
*
RETURN
*
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
*
    FN.CERTIFIED.CHEQUE.STOCK='F.CERTIFIED.CHEQUE.STOCK'
    F.CERTIFIED.CHEQUE.STOCK=''

    FN.CERTIFIED.CHEQUE.DETAILS='F.CERTIFIED.CHEQUE.DETAILS'
    F.CERTIFIED.CHEQUE.DETAILS=''

    FN.CERTIFIED.CHEQUE.DETAILS$HIS = 'F.CERTIFIED.CHEQUE.DETAILS$HIS'
    F.CERTIFIED.CHEQUE.DETAILS$HIS  = ''

    CALL OPF(FN.CERTIFIED.CHEQUE.DETAILS,F.CERTIFIED.CHEQUE.DETAILS)
    CALL OPF(FN.CERTIFIED.CHEQUE.DETAILS$HIS,F.CERTIFIED.CHEQUE.DETAILS$HIS)

    CALL OPF(FN.CERTIFIED.CHEQUE.STOCK,F.CERTIFIED.CHEQUE.STOCK)

    LREF.APP   = 'TELLER'
    LREF.FIELD = 'CERT.CHEQUE.NO' : @VM : 'L.TT.BENEFICIAR'
    LREF.POS   = ''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
    CERT.CHEQ.POS   = LREF.POS<1,1>
    BENEFICIARY.POS = LREF.POS<1,2>

RETURN
*
*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------
*
* update all the Cheque Informations in the Local tables certified.cheque.stock & certified.cheque.details
*
    Y.CERT.CHEQ.NO   = R.NEW(TT.TE.LOCAL.REF)<1,CERT.CHEQ.POS>
    IF R.NEW(TT.TE.DR.CR.MARKER) EQ "CREDIT" THEN
        Y.ACCOUNT.1      = R.NEW(TT.TE.ACCOUNT.1)<1,1>
        Y.ACCOUNT.2      = R.NEW(TT.TE.ACCOUNT.2)
        Y.AMOUNT.LOCAL.1 = R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1>
    END ELSE
        Y.ACCOUNT.1      = R.NEW(TT.TE.ACCOUNT.2)
        Y.ACCOUNT.2      = R.NEW(TT.TE.ACCOUNT.1)<1,1>
        Y.AMOUNT.LOCAL.1 = R.NEW(TT.TE.AMOUNT.LOCAL.2)
    END

    Y.VALUE.DATE.1   = R.NEW(TT.TE.VALUE.DATE.1)
    Y.CO.CODE        = R.NEW(TT.TE.CO.CODE)
    Y.NARRATIVE.1    = R.NEW(TT.TE.LOCAL.REF)<1,BENEFICIARY.POS>
    Y.STATUS         = R.NEW(TT.TE.RECORD.STATUS)

*
    CON.DATE = OCONV(DATE(),"D-")
    Y.DATE.TIME = CON.DATE[9,2]:CON.DATE[1,2]:CON.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]

*
    CALL F.READ(FN.CERTIFIED.CHEQUE.STOCK,Y.CERT.CHEQ.NO,R.CERT.CHEQ.STO,F.CERTIFIED.CHEQUE.STOCK,STO.ERR)
    CALL F.READ(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET,F.CERTIFIED.CHEQUE.DETAILS,DET.ERR)
*
    R.CERT.CHEQ.DET.HIST = R.CERT.CHEQ.DET

    IF Y.STATUS[1,1] EQ 'R' THEN
        R.CERT.CHEQ.STO<CERT.STO.STATUS> = 'CANCELLED'
        CALL F.WRITE(FN.CERTIFIED.CHEQUE.STOCK,Y.CERT.CHEQ.NO,R.CERT.CHEQ.STO)

        R.CERT.CHEQ.DET<CERT.DET.STATUS>     = 'CANCELLED'
        R.CERT.CHEQ.DET<CERT.DET.CURR.NO>    += 1
        R.CERT.CHEQ.DET<CERT.DET.INPUTTER>   = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.DATE.TIME>  = Y.DATE.TIME
        R.CERT.CHEQ.DET<CERT.DET.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.CO.CODE>    = Y.CO.CODE
* Update the $his file
        CERT.CHEQ.DET.HIST.ID = Y.CERT.CHEQ.NO :';': R.CERT.CHEQ.DET.HIST<CERT.DET.CURR.NO>
        CALL F.WRITE(FN.CERTIFIED.CHEQUE.DETAILS$HIS, CERT.CHEQ.DET.HIST.ID, R.CERT.CHEQ.DET.HIST)

* Update the Live file Now
        CALL F.WRITE(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET)

    END ELSE          ;*update certified.cheque.stock table

        R.CERT.CHEQ.STO<CERT.STO.STATUS>     = 'ISSUED'
        R.CERT.CHEQ.STO<CERT.STO.AMOUNT>     = Y.AMOUNT.LOCAL.1
        R.CERT.CHEQ.STO<CERT.STO.ACCOUNT.NO> = Y.ACCOUNT.1
        R.CERT.CHEQ.STO<CERT.STO.DATE>       = Y.VALUE.DATE.1
        R.CERT.CHEQ.STO<CERT.STO.COMP.CODE>  = Y.CO.CODE
        CALL F.WRITE(FN.CERTIFIED.CHEQUE.STOCK,Y.CERT.CHEQ.NO,R.CERT.CHEQ.STO)
*
* update certified.cheque.details table
*
        R.CERT.CHEQ.DET<CERT.DET.AMOUNT>        = Y.AMOUNT.LOCAL.1
        R.CERT.CHEQ.DET<CERT.DET.ACCOUNT>       = Y.ACCOUNT.1
        R.CERT.CHEQ.DET<CERT.DET.ISSUE.ACCOUNT> = Y.ACCOUNT.2
        R.CERT.CHEQ.DET<CERT.DET.DATE>          = Y.VALUE.DATE.1
        R.CERT.CHEQ.DET<CERT.DET.STATUS>        = 'ISSUED'
        R.CERT.CHEQ.DET<CERT.DET.TRANS.REF>     = ID.NEW
        R.CERT.CHEQ.DET<CERT.DET.COMP.CODE>     = Y.CO.CODE
        R.CERT.CHEQ.DET<CERT.DET.BENEFICIARY>   = Y.NARRATIVE.1
        R.CERT.CHEQ.DET<CERT.DET.INPUTTER>      = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.CURR.NO>       = '1'
        R.CERT.CHEQ.DET<CERT.DET.DATE.TIME>     = Y.DATE.TIME
        R.CERT.CHEQ.DET<CERT.DET.AUTHORISER>    = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.CERT.CHEQ.DET<CERT.DET.CO.CODE>       = Y.CO.CODE
        CALL F.WRITE(FN.CERTIFIED.CHEQUE.DETAILS,Y.CERT.CHEQ.NO,R.CERT.CHEQ.DET)
    END

RETURN
*-----------------------------------------------------------------------------
END
