* @ValidationCode : MjoxNDI3MDQ1NjUwOkNwMTI1MjoxNjgwMDcxMDgzNDMyOklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.V.BA.AA.REV.TXN

*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Edwin Charles D
* Program Name  : REDO.V.BA.AA.REV.TXN
*-------------------------------------------------------------------------
* Description: This routine is auth routine to process FT from REDO.FT.TT.TRANSACTION
*
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
* DATE         Name              ODR / HD REF              DESCRIPTION
* 14-06-17     Edwin Charles D   R15 Ugrade                Initial creation
** 30-03-2023 R22 Auto Conversion 
** 30-03-2023 Skanda R22 Manual Conversion - No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER
    $INSERT I_F.REDO.AA.ACTIVITY.LOG
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    IF V$FUNCTION EQ 'A' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN

INIT:
*---

    Y.VERSION.NAME = APPLICATION:PGM.VERSION
    Y.APPLICATION  = APPLICATION
    Y.OFS.BDY      = ''
    OFSVERSION     = ''
    Y.AA.COMPANY   = ''
    Y.ACTIVITY.REF = ID.NEW
    Y.INIT         = R.NEW(RE.LOG.INIT)
    Y.ACTIVITY     = FIELD(R.NEW(RE.LOG.ACTIVITY.NAME), '-', 2)
    Y.TXN.ID       = ''
    R.AA.ARRANGEMENT.ACTIVITY = ''
    R.FUNDS.TRANSFER = '' ;

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER = ''
    CALL OPF(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)

    FN.FUNDS.TRANSFER.HIS = 'F.FUNDS.TRANSFER$HIS'
    F.FUNDS.TRANSFER.HIS =''
    CALL OPF(FN.FUNDS.TRANSFER.HIS, F.FUNDS.TRANSFER.HIS)

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY, F.AA.ARRANGEMENT.ACTIVITY)

RETURN

PROCESS:
*------

    BEGIN CASE

        CASE Y.ACTIVITY EQ 'DISBURSE' AND Y.INIT EQ 'TRANSACTION'
            OFSVERSION = 'FUNDS.TRANSFER,REDO.AA.DISB.REV'
            GOSUB FT.REVERSE
            IF R.FUNDS.TRANSFER OR R.FUNDS.TRANSFER.HIS THEN
            END ELSE
                Y.TXN.ID   = ''
                OFSVERSION = ''
            END
        CASE Y.ACTIVITY EQ 'APPLYPAYMENT' AND Y.INIT EQ 'TRANSACTION'
            OFSVERSION = 'FUNDS.TRANSFER,REDO.REV.PAYMENT'
            GOSUB FT.REVERSE
            IF R.FUNDS.TRANSFER OR R.FUNDS.TRANSFER.HIS THEN
            END ELSE
                Y.TXN.ID   = ''
                OFSVERSION = ''
            END
        CASE Y.INIT EQ 'USER'
            OFSVERSION = 'AA.ARRANGEMENT.ACTIVITY,REDO.REV.AA'
            GOSUB AA.REVERSE
        CASE 1

    END CASE
    IF Y.TXN.ID AND OFSVERSION THEN
        GOSUB POST.FT.TXN
    END ELSE
        GOSUB PROGRAM.EXIT
    END

RETURN

FT.REVERSE:
*---------
    CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,Y.ACTIVITY.REF,R.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY,AAA.ERR)
    IF R.AA.ARRANGEMENT.ACTIVITY THEN
        Y.TXN.ID = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.TXN.CONTRACT.ID>
        CALL F.READ(FN.FUNDS.TRANSFER,Y.TXN.ID,R.FUNDS.TRANSFER,F.FUNDS.TRANSFER,FT.ERR)
        IF R.FUNDS.TRANSFER AND Y.TXN.ID[1,2] EQ 'FT' THEN
            Y.AA.COMPANY        = R.FUNDS.TRANSFER<FT.CO.CODE>
        END ELSE
            R.FUNDS.TRANSFER.HIS = '' ; Y.TXN.ID = Y.TXN.ID:';1'
            CALL F.READ(FN.FUNDS.TRANSFER.HIS,Y.TXN.ID,R.FUNDS.TRANSFER.HIS,F.FUNDS.TRANSFER.HIS,FT.ERR)
            Y.AA.COMPANY        = R.FUNDS.TRANSFER.HIS<FT.CO.CODE>
        END
    END

RETURN

AA.REVERSE:
*----------

    CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,Y.ACTIVITY.REF,R.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY,AAA.ERR)
    IF R.AA.ARRANGEMENT.ACTIVITY THEN
        Y.TXN.ID = Y.ACTIVITY.REF
        Y.AA.COMPANY = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.CO.CODE>
    END
RETURN

POST.FT.TXN:
*-----------

    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)

    Y.USR = OPERATOR
    CALL CACHE.READ(FN.USER, Y.USR, R.USR, ERR.US) ;** R22 Auto Conversion
    OFS.USERNAME = R.USR<EB.USE.SIGN.ON.NAME>
    OFS.PASSWORD = R.USR<EB.USE.PASSWORD>
    Y.OFS.MSG = ''
    Y.OFS.MSG = OFSVERSION:'/R/PROCESS,':OFS.USERNAME:'/':OFS.PASSWORD:'/':Y.AA.COMPANY:',':Y.TXN.ID

    ofsRequest = Y.OFS.MSG
    CALL ofs.addLocalRequest(ofsRequest,'add',error)
    MSG.OUT = ofsRequest

RETURN
PROGRAM.EXIT:
END
