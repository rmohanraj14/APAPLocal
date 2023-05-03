* @ValidationCode : MjoxMDQ5NzQ1NTIzOkNwMTI1MjoxNjgxMjE1MTY2MDAyOklUU1M6LTE6LTE6OTE5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 919
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.NOFILE.GETPER(R.DATA)
**
* Subroutine Type : ENQUIRY
* Attached to     : REDO.E.CH.GET.PERMISSION
* Attached as     : NOFILE.ROUTINE
* Primary Purpose : Get application permissions for Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
* 13/06/12 - Update
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 10-APR-2023     Conversion tool   R22 Auto conversion      VM to @VM, ++ to +=
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.USER.SMS.GROUP

    $INSERT I_F.REDO.IVR.PARAMS
    $INSERT I_F.REDO.CH.PROFILE
    $INSERT I_F.REDO.CH.CONFIG

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*----------
OPEN.FILES:
*----------

    FN.REDO.IVR.PARAMS = 'F.REDO.IVR.PARAMS'
    F.REDO.IVR.PARAMS = ''
    CALL OPF(FN.REDO.IVR.PARAMS,F.REDO.IVR.PARAMS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    CALL OPF(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)

    FN.REDO.CH.PROFILE = 'F.REDO.CH.PROFILE'
    F.REDO.CH.PROFILE = ''
    CALL OPF(FN.REDO.CH.PROFILE,F.REDO.CH.PROFILE)

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''
    CALL OPF(FN.REDO.CH.CONFIG,F.RECO.CH.CONFIG)

    FN.USER.SMS.GROUP = 'F.USER.SMS.GROUP'
    F.USER.SMS.GROUP = ''
    CALL OPF(FN.USER.SMS.GROUP,F.USER.SMS.GROUP)

RETURN

*-------
PROCESS:
*-------

    LOCATE "ACCT.USR" IN D.FIELDS<1> SETTING ACCT.POS THEN
        ACCT.USR = D.RANGE.AND.VALUE<ACCT.POS>
        COMI = ACCT.USR
        CALL IN2POSANT(19,'')
        ACCT.USR = COMI
    END

    LOCATE "OP.NO" IN D.FIELDS<1> SETTING OP.POS THEN
        OP.NO = D.RANGE.AND.VALUE<OP.POS>
    END

    GOSUB GET.ELEMENTS.FOR.OP
    GOSUB GET.AA.DETAILS

RETURN

*--------------
GET.AA.DETAILS:
*--------------
*Get the arrangement linked to Channel User using the Account Number inputted as parameter
    R.ACCT = ''; ACCT.ERR = ''
    CALL F.READ(FN.ACCOUNT,ACCT.USR,R.ACCT,F.ACCOUNT,ACCT.ERR)
    IF R.ACCT THEN
        CUSTOMER = R.ACCT<AC.CUSTOMER>
        CUS.IDS.REL = R.ACCT<AC.JOINT.HOLDER>
        CUS.IDS.TYPE = R.ACCT<AC.RELATION.CODE>
    END ELSE
        R.DATA<-1> = "7"
        RETURN
    END

    SEL.CMD = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':CUSTOMER:' AND CHANNEL EQ TELEFONO AND STATUS EQ ACTIVE'
    CALL EB.READLIST(SEL.CMD,NO.OF.REC,'',CNT.REC,RET.CD)
    IF CNT.REC EQ 1 THEN
        EXT.USR = NO.OF.REC<CNT.REC>
        R.REC = ''; RET.ERR = ''
        CALL F.READ(FN.REDO.CH.PROFILE,EXT.USR,R.REC,F.REDO.CH.PROFILE,RET.ERR)
        IF R.REC THEN
            Y.PROFILE.USER = R.REC<REDO.CH.PROF.PROFILE>
        END ELSE
            R.DATA<-1> = "4"
            RETURN
        END
    END ELSE
        R.DATA<-1> = "4"
        RETURN
    END

    GOSUB VERIFY.CUS.ACCT

    IF Y.OUT EQ 'Y' AND TYPE EQ 'V' THEN
        R.DATA<-1> = "2"
        RETURN
    END

    GOSUB GET.GP.FROM.PROFILE

RETURN

*-------------------
GET.GP.FROM.PROFILE:
*-------------------

    Y.USG.FOUND = ''
    R.REC = ''; RET.ERR = ''
    CALL CACHE.READ(FN.REDO.CH.CONFIG,'SYSTEM',R.REC,RET.ERR)
    Y.PROFILES = R.REC<REDO.CH.CONFIG.PROFILE.TYPE>
    Y.USGS = R.REC<REDO.CH.CONFIG.USER.SMS.GROUP>
    Y.TOT.PROFILES = DCOUNT(Y.PROFILES,@VM)
    Y.PROFILE.CNT = 1
    LOOP
    WHILE Y.PROFILE.CNT LE Y.TOT.PROFILES
        Y.PROFILE = FIELD(Y.PROFILES,@VM,Y.PROFILE.CNT)
        IF Y.PROFILE EQ Y.PROFILE.USER THEN
            Y.USG.FOUND = 'Y'
            GP = FIELD(Y.USGS,@VM,Y.PROFILE.CNT)
        END
        Y.PROFILE.CNT += 1
    REPEAT

    IF Y.USG.FOUND EQ '' THEN
        R.DATA<-1> = "5"
        RETURN
    END ELSE
        GOSUB CHECK.IT
    END

RETURN

*---------------
VERIFY.CUS.ACCT:
*---------------

    Y.OUT = ''

    Y.TOT.CUS.REL.TYPE = DCOUNT(CUS.IDS.TYPE,@VM)
    Y.CUS.REL.TYPE.CNT = 1
    LOOP
    WHILE Y.CUS.REL.TYPE.CNT LE Y.TOT.CUS.REL.TYPE
        Y.CUS.REL.TYPE.COMP = FIELD(CUS.IDS.TYPE,@VM,Y.CUS.REL.TYPE.CNT)
        IF Y.CUS.REL.TYPE.COMP EQ '500' THEN
            Y.OUT = 'Y'
            Y.CUS.REL.TYPE.CNT = Y.TOT.CUS.REL.TYPE
        END
        Y.CUS.REL.TYPE.CNT += 1
    REPEAT

RETURN

*-------------------
GET.ELEMENTS.FOR.OP:
*-------------------
* To get the elements to be checked to process the operation(application, version or enquiry and mode)
    R.REC = ''; RET.ERR = ''
    CALL F.READ(FN.REDO.IVR.PARAMS,OP.NO,R.REC,F.REDO.IVR.PARAMS,RET.ERR)
    IF R.REC THEN
        GETAPP = R.REC<REDO.IVR.PAR.APP.ENQ>
        GETFIELDMAP = R.REC<REDO.IVR.PAR.APP.MAP>
    END ELSE
        R.DATA<-1> = "3"
        RETURN
    END

    OPER = FIELD(GETFIELDMAP,@VM,1)
    OPER = FIELD(OPER,":",2)
    IF OPER EQ "" THEN
        ISVER = COUNT(GETAPP,",")
        IF ISVER EQ "1" THEN
            APPLI = FIELD(GETAPP,",",1)
            IF FIELD(GETAPP,",",2) EQ "" THEN
                TYPE = "A"
            END ELSE
                TYPE = "V"
                VER = GETAPP
                VER = "," : FIELD(VER,",",2)
            END
            FUNCT = "I"
        END ELSE
            TYPE = "A"
            APPLI = GETAPP
            FUNCT = "I"
        END
    END ELSE
        TYPE = "E"
        APPLI = GETAPP
        FUNCT = "S"
    END

RETURN

*--------
CHECK.IT:
*--------
* Check the permissions over the record in USER.SMS.GROUP application attached to User's arrangement

    BEGIN CASE
        CASE TYPE EQ "A"
            GOSUB VERIF.IF.APP
        CASE TYPE EQ "E"
            GOSUB VERIF.IF.ENQ
        CASE TYPE EQ "V"
            GOSUB VERIF.IF.VER
        CASE OTHERWISE
            R.DATA<-1> = "3"
    END CASE

RETURN

*--------
READ.USG:
*--------
* Read the record in USER.SMS.GROUP application
    R.REC = ''; RET.ERR = ''
    CALL F.READ(FN.USER.SMS.GROUP,GP,R.REC,F.USER.SMS.GROUP,RET.ERR)
    IF R.REC THEN
        APP.TOT = R.REC<EB.USG.APPLICATION>
        APP.TOT.CNT = DCOUNT(APP.TOT,@VM)
    END

RETURN

*------------
VERIF.IF.APP:
*------------

    GOSUB READ.USG
    CNT = 1
    LOOP
    WHILE CNT LE APP.TOT.CNT
        APP.EVAL = R.REC<EB.USG.APPLICATION><1,CNT>
        IF APPLI EQ APP.EVAL THEN
            FUNCT.TOT = R.REC<EB.USG.FUNCTION><1,CNT>
            FUNCT.TOT.CNT = DCOUNT(FUNCT.TOT," ")
            CNT2 = 1
            LOOP
            WHILE CNT2 LE FUNCT.TOT.CNT
                FUNCT.EVAL = FIELD(FUNCT.TOT," ",CNT2)
                IF FUNCT EQ FUNCT.EVAL THEN
                    R.DATA<-1> = "1"
                    RETURN
                END
                CNT2 += 1
            REPEAT
            R.DATA<-1> = "2"
            RETURN
        END
        CNT += 1
    REPEAT
    R.DATA<-1> = "2"

RETURN

*------------
VERIF.IF.ENQ:
*------------

    GOSUB READ.USG

    CNT = 1
    LOOP
    WHILE CNT LE APP.TOT.CNT
        APP.EVAL = R.REC<EB.USG.APPLICATION><1,CNT>
        ENQ.EVAL = R.REC<EB.USG.DATA.FROM><1,CNT>
        IF APP.EVAL EQ "ENQUIRY.SELECT" AND APPLI EQ ENQ.EVAL THEN
            FUNCT.TOT = R.REC<EB.USG.FUNCTION><1,CNT>
            FUNCT.TOT.CNT = DCOUNT(FUNCT.TOT," ")
            CNT.F = 1
            LOOP
            WHILE CNT.F LE FUNCT.TOT.CNT
                FUNCT.EVAL = FIELD(FUNCT.TOT," ",CNT.F)
                IF FUNCT EQ FUNCT.EVAL THEN
                    R.DATA<-1> = "1"
                    RETURN
                END
                CNT.F += 1
            REPEAT
        END
        CNT += 1
    REPEAT
    R.DATA<-1> = "2"

RETURN

*------------
VERIF.IF.VER:
*------------

    GOSUB READ.USG

    CNT = 1
    LOOP
    WHILE CNT LE APP.TOT.CNT
        APP.EVAL = R.REC<EB.USG.APPLICATION><1,CNT>
        IF APPLI EQ APP.EVAL THEN
            VER.TOT = R.REC<EB.USG.VERSION><1,CNT>
            VER.TOT.CNT = DCOUNT(VER.TOT,@VM)
            CNT2 = 1
            LOOP
            WHILE CNT2 LE VER.TOT.CNT
                VER.EVAL = FIELD(VER.TOT," ",CNT2)
                IF VER EQ VER.EVAL THEN
                    FUNCT.TOT = R.REC<EB.USG.FUNCTION><1,CNT>
                    FUNCT.TOT.CNT = DCOUNT(FUNCT.TOT," ")
                    CNT3 = 1
                    LOOP
                    WHILE CNT3 LE FUNCT.TOT.CNT
                        FUNCT.EVAL = FIELD(FUNCT.TOT," ",CNT3)
                        IF FUNCT EQ FUNCT.EVAL THEN
                            R.DATA<-1> = "1"
                            RETURN
                        END
                        CNT3 += 1
                    REPEAT
                END
                CNT2 += 1
            REPEAT
        END
        CNT += 1
    REPEAT
    R.DATA<-1> = "2"

RETURN

END
