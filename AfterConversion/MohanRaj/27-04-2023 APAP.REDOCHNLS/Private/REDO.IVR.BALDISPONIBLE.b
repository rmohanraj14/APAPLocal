* @ValidationCode : MjoxMzI2OTIxMjgyOkNwMTI1MjoxNjgxMzgwODYwNzc4OklUU1M6LTE6LTE6MTc5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 179
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.BALDISPONIBLE(R.DATA)
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is an Nofile routine as a part of enquiry REDO.IVR.BALDISPONIBLE for
* C.3 IVR to define if an account has the enough balance to cover the amount
* of a transaction.
*
*
* Input/Output:
*--------------
* IN : ACCONT.NO, AMOUNT
* OUT : R.DATA (ALL DATA)
*---------------
*-----------------------------------------------------------------------------
* Modification History :
* Date Who Reference Description
* 16-FEB-2011 RMONDRAGON ODR-2011-02-0099 FIRST VERSION
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
* </region>
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN

*****
INIT:
*****

    Y.APPL = "ACCOUNT"
    Y.FLD = "L.AC.AV.BAL"
    Y.POS = ""
    CALL GET.LOC.REF(Y.APPL,Y.FLD,Y.POS)
    Y.AV.BAL.POS = Y.POS<1,1>

RETURN

**********
OPENFILES:
**********

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN

********
PROCESS:
********

    LOCATE "ACCOUNT.NO" IN D.FIELDS<1> SETTING ACCOUNT.NO.POS THEN
        Y.ACCOUNT.NO = D.RANGE.AND.VALUE<ACCOUNT.NO.POS>
        COMI = Y.ACCOUNT.NO
        CALL IN2POSANT(19,'')
        Y.ACCOUNT.NO = COMI
    END

    LOCATE "AMOUNT" IN D.FIELDS<1> SETTING AMOUNT.POS THEN
        Y.AMOUNT = D.RANGE.AND.VALUE<AMOUNT.POS>
    END

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.NO,Y.ACCOUNT.REC,F.ACCOUNT,ACCOUNT.ERR)
    IF Y.ACCOUNT.REC THEN
        Y.AV.BAL = Y.ACCOUNT.REC<AC.LOCAL.REF><1,Y.AV.BAL.POS>
    END ELSE
        R.DATA<-1> = "2"
        RETURN
    END

    IF Y.AMOUNT LE Y.AV.BAL THEN
        R.DATA<-1> = "T"
    END ELSE
        R.DATA<-1> = "F"
    END

RETURN

END
