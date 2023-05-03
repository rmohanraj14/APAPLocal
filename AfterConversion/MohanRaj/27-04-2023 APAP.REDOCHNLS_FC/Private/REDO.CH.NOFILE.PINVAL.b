* @ValidationCode : MjotNzA5NTMxMzg5OkNwMTI1MjoxNjgxMjE1MTY2MTI0OklUU1M6LTE6LTE6NDU3OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 457
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.NOFILE.PINVAL(R.DATA)
**
* Subroutine Type : ENQUIRY
* Attached to     : REDO.E.CH.PINVAL
* Attached as     : NOFILE.ROUTINE
* Primary Purpose : Define the status of PIN number assigned to Channel User.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version.
*           ODR Reference: ODR-2010-06-0155.
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
*
* 16/11/10 - Use of CACHE.READ command instead of F.READ command to read the
*            record SYSTEM in REDO.CH.CONFIG local application.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
*  5/12/11 - Update to key for PIN encryption.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 17/01/13 - Update to check the account.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 04-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM, ++ to +=, F.READ to CACHE.READ
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_ENQUIRY.COMMON

    $INSERT I_F.REDO.CH.PINADM
    $INSERT I_F.REDO.CH.CONFIG
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.ACCOUNT

    R.PIN = ""
    PN = ""
    TYPE = ""
    ESTADO = ""
    VTP = ""
    SD = ""
    ST = ""
    ENDVALTIME = ""
    STARTVALTIME = ""
    STD = ""
    ESTADOUSR = ""
    CUSTOMER = ""
    Y.PN.SET = ""

    FN.REDO.CH.PINADM = 'F.REDO.CH.PINADM'
    F.REDO.CH.PINADM = ''
    CALL OPF(FN.REDO.CH.PINADM,F.REDO.CH.PINADM)

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''
*    CALL OPF(FN.REDO.CH.CONFIG,F.REDO.CH.CONFIG) ;* OPF commented as CACHE.READ used

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    CALL OPF(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)

    LOCATE "ACCT.USR" IN D.FIELDS<1> SETTING ACCT.USR.POS THEN
        ACCT.USR = D.RANGE.AND.VALUE<ACCT.USR.POS>
        COMI = ACCT.USR
        CALL IN2POSANT(19,'')
        ACCT.USR = COMI
    END

    LOCATE "PIN.USR" IN D.FIELDS<1> SETTING PIN.POS THEN
        PIN.USR = D.RANGE.AND.VALUE<PIN.POS>
    END

    GOSUB CHECK.VALID.USER

RETURN

*-----------------------------------------------------------------------------
CHECK.VALID.USER:

    R.ACCT = ''; ACCT.ERR = ''
    CALL F.READ(FN.ACCOUNT,ACCT.USR,R.ACCT,F.ACCOUNT,ACCT.ERR)
    IF R.ACCT THEN
        CUSTOMER = R.ACCT<AC.CUSTOMER>
        Y.CO.SET = R.ACCT<AC.JOINT.HOLDER>
        Y.CO.TYPE.SET = R.ACCT<AC.RELATION.CODE>
        GOSUB GET.CUS.REL
    END ELSE
        ESTADO = "U"
        GOSUB DEFINE.STATUS
        RETURN
    END

    Y.TOT.CUSTOMER.SET = DCOUNT(Y.CUSTOMER.SET,@VM)
    Y.CNT.CUSTOMER = 1
    LOOP
    WHILE Y.CNT.CUSTOMER LE Y.TOT.CUSTOMER.SET
        CUSTOMER = FIELD(Y.CUSTOMER.SET,@VM,Y.CNT.CUSTOMER)
        GOSUB CHECK.EACH.CUS.REL
        Y.CNT.CUSTOMER += 1
    REPEAT

    Y.PN.IDEN = ''
    Y.TOT.PN.SET = DCOUNT(Y.PN.SET,@VM) - 1
    Y.CNT.PN = 1
    LOOP
    WHILE Y.CNT.PN LE Y.TOT.PN.SET
        PN.TO.CHECK = FIELD(Y.PN.SET,@VM,Y.CNT.PN)
        IF PIN.USR EQ PN.TO.CHECK THEN
            ESTADO = FIELD(ESTADO,@VM,Y.CNT.PN)
            GOSUB DEFINE.STATUS
            Y.PN.IDEN = 'Y'
            Y.CNT.PN = Y.TOT.PN.SET
        END
        Y.CNT.PN += 1
    REPEAT

    IF Y.PN.IDEN EQ '' THEN
        ESTADO = "I"
        GOSUB DEFINE.STATUS
    END

RETURN

*------------------------------------------------------------------------------
GET.CUS.REL:

    Y.CUSTOMER.SET = ''

    IF Y.CO.SET NE '' THEN
        Y.TOT.CO.TYPE.SET = DCOUNT(Y.CO.TYPE.SET,@VM)
        Y.CNT.CO.TYPE = 1
        LOOP
        WHILE Y.CNT.CO.TYPE LE Y.TOT.CO.TYPE.SET
            Y.CO.TYPE = FIELD(Y.CO.TYPE.SET,@VM,Y.CNT.CO.TYPE)
            IF Y.CO.TYPE NE '500' THEN
                Y.CUSTOMER.SET := FIELD(Y.CO.SET,@VM,Y.CNT.CO.TYPE):@VM
            END
            Y.CNT.CO.TYPE += 1
        REPEAT
    END

    Y.CUSTOMER.SET = CUSTOMER:@VM:Y.CUSTOMER.SET

RETURN

*------------------------------------------------------------------------------
CHECK.EACH.CUS.REL:

    SEL.CMD = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':CUSTOMER:' AND CHANNEL EQ TELEFONO AND STATUS EQ ACTIVE'
    CALL EB.READLIST(SEL.CMD,NO.OF.REC,'',CNT.REC,RET.CD)
    IF CNT.REC EQ 1 THEN
        EXT.USR = NO.OF.REC<CNT.REC>
        R.USR = ''; USR.ERR = ''
        CALL CACHE.READ(FN.EB.EXTERNAL.USER, EXT.USR, R.USR, USR.ERR) ;*R22 Auto conversion
        IF R.USR THEN
            ESTADOUSR = R.USR<EB.XU.STATUS>
        END ELSE
            Y.PN.SET := PN:@VM
            ESTADO := "I":@VM
            RETURN
        END
    END ELSE
        Y.PN.SET := PN:@VM
        ESTADO := "UDE":@VM
        RETURN
    END

    IF ESTADOUSR EQ "ACTIVE" THEN
        GOSUB CHECK.PIN
    END ELSE
        Y.PN.SET := PN:@VM
        ESTADO := "UDE":@VM
        RETURN
    END

RETURN

*-----------------------------------------------------------------------------
CHECK.PIN:

*Find the type of PIN number created for the customer.
    R.PIN = ''; PIN.ERR = ''
    CALL F.READ(FN.REDO.CH.PINADM,EXT.USR,R.PIN,F.REDO.CH.PINADM,PIN.ERR)
    IF R.PIN THEN
        PN = R.PIN<REDO.CH.PINADMIN.PIN>
        TYPE = R.PIN<REDO.CH.PINADMIN.TYPE>
    END ELSE
        Y.PN.SET := PN:@VM
        ESTADO := "I":@VM
        RETURN
    END

    KY = "7"
    PN = DECRYPT(PN,KY,2)

    IF PIN.USR EQ PN THEN
        IF TYPE EQ "TEMPORAL" THEN
            GOSUB CHECK.VALID.PIN
        END ELSE
            Y.PN.SET := PN:@VM
            ESTADO := "V":@VM
            RETURN
        END
    END ELSE
        Y.PN.SET := PN:@VM
        ESTADO := "I":@VM
        RETURN
    END

RETURN
*-----------------------------------------------------------------------------
CHECK.VALID.PIN:

    CONFIG.ID = "SYSTEM"
    CALL CACHE.READ(FN.REDO.CH.CONFIG,CONFIG.ID,R.CON,CONFIG.ERR)
    VTP = R.CON<REDO.CH.CONFIG.VALTIMEPIN>
    VTP = VTP * 60

    SD = R.PIN<REDO.CH.PINADMIN.START.DATE>
    ST = R.PIN<REDO.CH.PINADMIN.START.TIME>

    ENDVALTIME = TIME()
    STARTVALTIME = ENDVALTIME - VTP

    STD = FIELD(ST,":",1) * 3600
    STD += FIELD(ST,":",2) * 60
    STD += FIELD(ST,":",3)

    IF SD EQ TODAY THEN
        IF STD GE STARTVALTIME AND STD LE ENDVALTIME THEN
            Y.PN.SET := PN:@VM
            ESTADO := "VT":@VM
            RETURN
        END ELSE
            Y.PN.SET := PN:@VM
            ESTADO := "I":@VM
            RETURN
        END
    END ELSE
        Y.PN.SET := PN:@VM
        ESTADO := "I":@VM
        RETURN
    END

RETURN
*-----------------------------------------------------------------------------
DEFINE.STATUS:

    BEGIN CASE        ;* converted if statements to case statements - start
        CASE ESTADO EQ "V"
            R.DATA<-1> = "1"
            RETURN
        CASE ESTADO EQ "I"
            R.DATA<-1> = "4"
            RETURN
        CASE ESTADO EQ "UDE"
            R.DATA<-1> = "2"
            RETURN
        CASE ESTADO EQ "VT"
            R.DATA<-1> = "6"
            RETURN
        CASE 1
            R.DATA<-1> = "7"
            RETURN
    END CASE          ;* converted if statements to case statements - End

RETURN
*-----------------------------------------------------------------------------
END
