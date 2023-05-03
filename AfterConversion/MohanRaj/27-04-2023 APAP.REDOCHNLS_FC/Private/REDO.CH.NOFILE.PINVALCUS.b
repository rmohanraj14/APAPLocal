* @ValidationCode : MjoyMDExMDk4NDg2OkNwMTI1MjoxNjgxMjE1MTY2MTkxOklUU1M6LTE6LTE6NDY1OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 465
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.NOFILE.PINVALCUS(R.DATA)
**
* Subroutine Type : ENQUIRY
* Attached to     : REDO.E.CH.PINVALCUS
* Attached as     : NOFILE.ROUTINE
* Primary Purpose : Define the status of PIN number assigned to Channel User.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 4/05/15 - First Version.
*           ODR Reference: ODR-2010-06-0155.
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
*
* 04-APR-2023     Conversion tool    R22 Auto conversion       F.READ to CACHE.READ
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_ENQUIRY.COMMON

    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.CH.PINADM
    $INSERT I_F.REDO.CH.CONFIG
    $INSERT I_F.EB.EXTERNAL.USER

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

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.CH.PINADM = 'F.REDO.CH.PINADM'
    F.REDO.CH.PINADM = ''
    CALL OPF(FN.REDO.CH.PINADM,F.REDO.CH.PINADM)

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    CALL OPF(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)

    LOCATE "CUSTOMER" IN D.FIELDS<1> SETTING CUSTOMER.POS THEN
        CUSTOMER = D.RANGE.AND.VALUE<CUSTOMER.POS>
    END

    LOCATE "PIN.USR" IN D.FIELDS<1> SETTING PIN.POS THEN
        PIN.USR = D.RANGE.AND.VALUE<PIN.POS>
    END

    GOSUB CHECK.VALID.USER

RETURN

*-----------------------------------------------------------------------------
CHECK.VALID.USER:

    R.CUSTOMER = ''; CUST.ERR = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUST.ERR)
    IF NOT(R.CUSTOMER) THEN
        ESTADO = "U"
        GOSUB DEFINE.STATUS
        RETURN
    END

    GOSUB CHECK.EXT.USER
    GOSUB DEFINE.STATUS

RETURN

*------------------------------------------------------------------------------
CHECK.EXT.USER:

    SEL.CMD = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':CUSTOMER:' AND CHANNEL EQ TELEFONO AND STATUS EQ ACTIVE'
    CALL EB.READLIST(SEL.CMD,NO.OF.REC,'',CNT.REC,RET.CD)
    IF CNT.REC EQ 1 THEN
        EXT.USR = NO.OF.REC<CNT.REC>
        R.USR = ''; USR.ERR = ''
        CALL CACHE.READ(FN.EB.EXTERNAL.USER, EXT.USR, R.USR, USR.ERR) ;*R22 Auto conversion
        IF R.USR THEN
            ESTADOUSR = R.USR<EB.XU.STATUS>
        END ELSE
            ESTADO = "I"
            RETURN
        END
    END ELSE
        ESTADO = "UDE"
        RETURN
    END

    IF ESTADOUSR EQ "ACTIVE" THEN
        GOSUB CHECK.PIN
    END ELSE
        ESTADO = "UDE"
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
        ESTADO = "I"
        RETURN
    END

    KY = "7"
    PN = DECRYPT(PN,KY,2)

    IF PIN.USR EQ PN THEN
        IF TYPE EQ "TEMPORAL" THEN
            GOSUB CHECK.VALID.PIN
        END ELSE
            ESTADO = "V"
            RETURN
        END
    END ELSE
        ESTADO = "I"
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
            ESTADO = "VT"
            RETURN
        END ELSE
            ESTADO = "I"
            RETURN
        END
    END ELSE
        ESTADO = "I"
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
