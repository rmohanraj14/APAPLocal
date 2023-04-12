* @ValidationCode : MjotMTg0NDkyMjM3NzpDcDEyNTI6MTY4MTI4Njc0MjEwMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:35:42
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
SUBROUTINE REDO.V.AUT.PAYROLL.FILE
*-----------------------------------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.AUT.PAYROLL.FILE
*-----------------------------------------------------------------------------------------------------------
*DESCRIPTION       :It is the input routine to validate the credit and debit accounts
*
*
*LINKED WITH       :

* ----------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who                     Reference            Description
*===========        ====================       ===============     ==================
* 29-12-2010        Sakthi Sellappillai        ODR-2010-08-0031     Initial Creation
* 05-06-2010       GANESH H                    PACS00072713         MODIFICATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,F.READ TO CACHE.READ
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_EB.EXTERNAL.COMMON
    $INSERT I_F.EB.FILE.UPLOAD.TYPE
    $INSERT I_F.EB.FILE.UPLOAD.PARAM
    $INSERT I_F.EB.FILE.UPLOAD
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AC.ENTRY.PARAM
    $INSERT I_System
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER

    GOSUB INITIALISE
    GOSUB COPY.FILE
RETURN
*-----------------------------------------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------------------------------------

    APPL.ARRAY = "EB.FILE.UPLOAD":@FM:"ACCOUNT"
    FIELD.ARRAY = "L.PR.PMT.DATE":@VM:"L.PR.DEB.ACCT":@VM:"L.PR.PMT.CUR":@FM:"L.AC.AV.BAL":@VM:"L.AC.STATUS1"
    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FIELD.ARRAY,FIELD.POS)
    Y.LOC.PR.PMT.DATE.POS = FIELD.POS<1,1>
    Y.LOC.PR.DEB.ACCT.POS = FIELD.POS<1,2>
    Y.LOC.PR.PMT.CUR.POS  = FIELD.POS<1,3>
    Y.LOC.AC.BAL.VAL.POS = FIELD.POS<2,1>
    Y.LOC.AC.STAT.VAL.POS = FIELD.POS<2,2>

    Y.OFS.MSG.ID.VAL = ''

    FN.FILE.UP.TYPE='F.EB.FILE.UPLOAD.TYPE'
    F.FILE.UP.TYPE=''
    R.UP.TYPE = ''
    UP.TYPE.ERR = ''
    CALL OPF(FN.FILE.UP.TYPE,F.FILE.UP.TYPE)

    FN.AI.REDO.ARCIB.PARAMETER = 'F.AI.REDO.ARCIB.PARAMETER'
    F.AI.REDO.ARCIB.PARAMETER  = ''
    CALL OPF(FN.AI.REDO.ARCIB.PARAMETER,F.AI.REDO.ARCIB.PARAMETER)


*  CALL F.READ(FN.AI.REDO.ARCIB.PARAMETER,'SYSTEM',R.AI.REDO.ARCIB.PARAMETER,F.AI.REDO.ARCIB.PARAMETER,AI.REDO.ARCIB.PARAMETER.ERR) ;*Tus Start
    CALL CACHE.READ(FN.AI.REDO.ARCIB.PARAMETER,'SYSTEM',R.AI.REDO.ARCIB.PARAMETER,AI.REDO.ARCIB.PARAMETER.ERR) ; * Tus End
    Y.FILE.DEST.PATH    = R.AI.REDO.ARCIB.PARAMETER<AI.PARAM.UPLOAD.PATH>

    FN.EB.FILE.UPLOAD.PARAM = 'F.EB.FILE.UPLOAD.PARAM'
    F.EB.FILE.UPLOAD.PARAM = ''
    R.EB.FILE.UPLOAD.PARAM = ''
    Y.EB.FILE.UPLOAD.PARMA.ERR = ''
    CALL OPF(FN.EB.FILE.UPLOAD.PARAM,F.EB.FILE.UPLOAD.PARAM)

    FN.REDO.EB.USER.PRINT.VAR='F.REDO.EB.USER.PRINT.VAR'
    F.REDO.EB.USER.PRINT.VAR=''
    CALL OPF(FN.REDO.EB.USER.PRINT.VAR,F.REDO.EB.USER.PRINT.VAR)


*  CALL F.READ(FN.EB.FILE.UPLOAD.PARAM,'SYSTEM',R.EB.FILE.UPLOAD.PARAM,F.EB.FILE.UPLOAD.PARAM,Y.EB.FILE.UPLOAD.PARMA.ERR) ;*Tus Start
    CALL CACHE.READ(FN.EB.FILE.UPLOAD.PARAM,'SYSTEM',R.EB.FILE.UPLOAD.PARAM,Y.EB.FILE.UPLOAD.PARMA.ERR) ; * Tus End
    IF NOT(Y.EB.FILE.UPLOAD.PARMA.ERR) THEN
        Y.UPLOAD.PARAM.VAL = R.EB.FILE.UPLOAD.PARAM<EB.UP.TC.UPLOAD.PATH>
    END

    Y.UPLOAD.FILE.TYPE.VAL = R.NEW(EB.UF.UPLOAD.TYPE)
    Y.PAY.DATE  = R.NEW(EB.UF.LOCAL.REF)<1,Y.LOC.PR.PMT.DATE.POS>
    Y.FILE.CURRENCY  = R.NEW(EB.UF.LOCAL.REF)<1,Y.LOC.PR.PMT.CUR.POS>
    Y.SRC.ACCOUNT = R.NEW(EB.UF.LOCAL.REF)<1,Y.LOC.PR.DEB.ACCT.POS>
    Y.FILE.DESC =   R.NEW(EB.UF.DESCRIPTION)

    CALL CACHE.READ(FN.FILE.UP.TYPE, Y.UPLOAD.FILE.TYPE.VAL, R.UP.TYPE, UP.TYPE.ERR) ;*R22 Auto Code Conversion
    IF NOT(UP.TYPE.ERR) THEN
        Y.UPLOAD.DIR.VAL = R.UP.TYPE<EB.UT.UPLOAD.DIR>
    END
    Y.SYMBOL.DIR = Y.UPLOAD.DIR.VAL[1,1]
    IF Y.SYMBOL.DIR NE '/' THEN
        Y.FILE.PATH = Y.UPLOAD.PARAM.VAL:"/":Y.UPLOAD.DIR.VAL
    END ELSE
        Y.FILE.PATH = Y.UPLOAD.PARAM.VAL:Y.UPLOAD.DIR.VAL
    END

    FN.FILE.PATH = Y.FILE.PATH
    F.FILE.PATH  =''
    CALL OPF(FN.FILE.PATH,F.FILE.PATH)
    R.FILE.PATH.REC = ''
    Y.FILE.PATH.ERR = ''
    Y.UPLOAD.FILE.NAME = R.NEW(EB.UF.SYSTEM.FILE.NAME)
    Y.UPLOAD.FILE.ID = Y.UPLOAD.FILE.NAME['|',1,1]
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT =''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    FN.AC.ENTRY.PARAM='F.AC.ENTRY.PARAM'
    R.ACCOUNT.REC = ''
    Y.ACCT.ERR = ''
    Y.CUST.ACCT.ERR = ''
    Y.CUSTOMER = ''
    Y.AMOUNT = ''
RETURN
*---------*
COPY.FILE:
*---------*

    IF ETEXT EQ '' THEN
        NEW.FILEID.1=FIELD(Y.UPLOAD.FILE.ID,'.',1)
        NEW.FILEID.2=FIELD(Y.UPLOAD.FILE.ID,'.',2)
        NEW.FILEID.3=FIELD(Y.UPLOAD.FILE.ID,'.',3)

        FINAL.FILE.ID=NEW.FILEID.1:".T24.":NEW.FILEID.2:NEW.FILEID.3:".":Y.FILE.CURRENCY:".":Y.SRC.ACCOUNT:".":Y.PAY.DATE
        Y.CPY.CMD = 'COPY FROM ':Y.FILE.PATH:' TO ':Y.FILE.DEST.PATH:' ': Y.UPLOAD.FILE.ID:',':FINAL.FILE.ID
        EXECUTE Y.CPY.CMD
        CALL F.DELETE(FN.FILE.PATH,Y.UPLOAD.FILE.ID)


*    WRITE Y.FILE.DESC TO F.REDO.EB.USER.PRINT.VAR,FINAL.FILE.ID ;*Tus Start
        CALL F.WRITE(FN.REDO.EB.USER.PRINT.VAR,FINAL.FILE.ID,Y.FILE.DESC);*Tus End


    END
RETURN
*PACS00072713-E
END
*---------------------------------------------*END OF SUBROUTINE*-------------------------------------------
