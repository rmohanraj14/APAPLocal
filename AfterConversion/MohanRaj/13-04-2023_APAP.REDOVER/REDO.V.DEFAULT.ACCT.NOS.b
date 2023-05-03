* @ValidationCode : MjoyMTIyNzM0NDg6Q3AxMjUyOjE2ODEzODcyNTQwNDY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:30:54
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
SUBROUTINE REDO.V.DEFAULT.ACCT.NOS
*-----------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : TAM
* Program Name  : REDO.V.DEFAULT.ACCT.NOS
* ODR NUMBER    : ODR-2009-10-0795
*-------------------------------------------------------------------------------------------------
* Description   : This routine is used in FT Version to default the credit and debit account nos
* In parameter  : none
* out parameter : none
*-------------------------------------------------------------------------------------------------
* Modification History :
*-------------------------------------------------------------------------------------------------
*   DATE             WHO             REFERENCE         DESCRIPTION
* 14-01-2011      MARIMUTHU s     ODR-2009-10-0795  Initial Creation
* 13 jul 2011     Marimuthu S     PACS00062902
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     IF Condition Added,VM TO @VM,FM TO@FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.PAY.MODE.PARAM
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.H.INVENTORY.PARAMETER
    $INSERT I_F.REDO.ADMIN.CHQ.PARAM
    $INSERT I_System
    $INSERT I_F.ACCOUNT

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.REDO.H.PAY.MODE.PARAM = 'F.REDO.H.PAY.MODE.PARAM'
    F.REDO.H.PAY.MODE.PARAM = ''

*    FN.CATEG.INT.ACCT = 'F.CATEG.INT.ACCT'
*    F.CATEG.INT.ACCT = ''
* PACS00062902 -s
    FN.REDO.H.INVENTORY.PARAMETER = 'F.REDO.H.INVENTORY.PARAMETER'
    F.REDO.H.INVENTORY.PARAMETER = ''

    FN.REDO.ADMIN.CHQ.PARAM = 'F.REDO.ADMIN.CHQ.PARAM'
    F.REDO.ADMIN.CHQ.PARAM = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

* PACS00062902 -e

RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    Y.AC.NO = System.getVariable("CURRENT.DEP.ACC")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.AC.NO = ""
    END ;*R22 Auto code conversion-END

    CALL F.READ(FN.ACCOUNT,Y.AC.NO,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.ACC.CUR = R.ACCOUNT<AC.CURRENCY>

    IF Y.ACC.CUR ELSE
        Y.ACC.CUR = LCCY
    END

    CALL CACHE.READ(FN.REDO.H.PAY.MODE.PARAM,'SYSTEM',R.REDO.H.PAY.MODE.PARAM,F.REDO.H.PAY.MODE.PARAM)
    Y.PAYMNT.MODE = R.REDO.H.PAY.MODE.PARAM<REDO.H.PAY.PAYMENT.MODE>
    Y.PAYMNT.MODE = CHANGE(Y.PAYMNT.MODE,@VM,@FM)
    LOCATE 'Admin.check' IN Y.PAYMNT.MODE SETTING POS THEN
        LOCATE Y.ACC.CUR IN R.REDO.H.PAY.MODE.PARAM<REDO.H.PAY.CURRENCY,POS,1> SETTING Y.AS THEN
            Y.DEB.ACCT.NO = R.REDO.H.PAY.MODE.PARAM<REDO.H.PAY.ACCOUNT.NO,POS,Y.AS>
        END
    END
* PACS00062902 -s
*   CALL CACHE.READ(FN.CATEG.INT.ACCT,'15005',R.CATEG.INT.ACCT,F.CATEG.INT.ACCT)
*   Y.CRED.ACCT.NO = R.CATEG.INT.ACCT<1>

    CALL CACHE.READ(FN.REDO.H.INVENTORY.PARAMETER,'SYSTEM',R.INVENTORY.PARAM,INV.PAR.ERR)
    Y.INV.METHOD = R.INVENTORY.PARAM<IN.PR.INV.MAINT.TYPE>
*    Y.ADMIN.TYPE = R.INVENTORY.PARAM<IN.PR.INV.ADMIN.TYPE>
*    LOCATE 'ADMIN.CHEQUES' IN Y.INV.METHOD<1,1> SETTING POS.ADM THEN
*   LOCATE 'GOVT' IN Y.ADMIN.TYPE<1,1> SETTING POS.ADM THEN

*   Y.ITEM.CODE = R.INVENTORY.PARAM<IN.PR.ITEM.CODE,POS.ADM>
    Y.ITEM.CODE = '3454'
*  END

    CALL CACHE.READ(FN.REDO.ADMIN.CHQ.PARAM,'SYSTEM',R.ADMIN.CHQ.PARAM,ADM.CHQ.ERR)
    Y.PARAM.ITEM.CODES = R.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ITEM.CODE>
    LOCATE Y.ITEM.CODE IN Y.PARAM.ITEM.CODES<1,1> SETTING POS.PAR THEN
        Y.CRED.ACCT.NO = R.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ACCOUNT,POS.PAR>
    END
* PACS00062902 -e

    R.NEW(FT.DEBIT.ACCT.NO) = Y.DEB.ACCT.NO
    R.NEW(FT.CREDIT.ACCT.NO) = Y.CRED.ACCT.NO

RETURN
*-----------------------------------------------------------------------------
END
