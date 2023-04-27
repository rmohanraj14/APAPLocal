* @ValidationCode : Mjo5NTEzOTY5NzI6Q3AxMjUyOjE2ODEzODA4NDk2NTg6SVRTUzotMTotMTo4NDU6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 845
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.EMAIL
*******************************
* Subroutine Type : VERSION
* Attached to : AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINT,
* AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWTEL,
* AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXINP,
* AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXAUTH,
* AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXADM,
* Attached as : Field CUSTOMER as VALIDATION.RTN
* Primary Purpose : Validate if Customer has an email registered in CUSTOMER for
* their Internet Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 5/10/11 - First Version
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
* 4/07/12 - Update for validate customer type and status
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
* 29/08/12 - Update for validate customer under corporate user creation
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
* 11/01/13 - Update for validate if customer has email registered during telephone user creation
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
* 09/04/13 - Update to define the process of mail sending and PIN definition just once
* during user creation process.
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM, = to EQ
* 11-APR-2023      Harishvikram C   Manual R22 conversion      CALL routine format modified

*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.CUSTOMER.STATUS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.DOCUMENT.STATUS
    $INSERT JBC.h

    $INSERT I_REDO.CH.V.EMAIL.COMMON
    $INSERT I_F.REDO.CH.PREV.DBCM
    $INSERT I_F.REDO.INTERFACE.ACT
    $INSERT I_F.REDO.INTERFACE.ACT.DETAILS

    GOSUB INITIALIZE
    GOSUB PROCESS

RETURN

***********
INITIALIZE:
***********

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CUSTOMER.STATUS = 'F.CUSTOMER.STATUS'
    F.CUSTOMER.STATUS = ''
    CALL OPF(FN.CUSTOMER.STATUS,F.CUSTOMER.STATUS)

    FN.CUST.DOCUMENT = 'F.CUST.DOCUMENT'
    F.CUST.DOCUMENT = ''
    CALL OPF(FN.CUST.DOCUMENT,F.CUST.DOCUMENT)

    FN.DOCUMENT.STATUS = 'F.DOCUMENT.STATUS'
    F.DOCUMENT.STATUS = ''
    CALL OPF(FN.DOCUMENT.STATUS,F.DOCUMENT.STATUS)

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'

    LREF.APP = 'CUSTOMER'
    LREF.FIELDS = 'L.CU.TIPO.CL'
    LREF.POS = ''
    CALL GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)

    L.CU.TIPO.CL.POS = LREF.POS<1,1>

    Y.EMAIL.REG = ''

    FN.REDO.CH.PREV.DBCM = 'F.REDO.CH.PREV.DBCM'
    F.REDO.CH.PREV.DBCM = ''
    CALL OPF(FN.REDO.CH.PREV.DBCM,F.REDO.CH.PREV.DBCM)

    INT.CODE = 'C2401'
    INT.TYPE = 'ONLINE'
    BAT.NO = ''
    BAT.TOT = ''
    INFO.OR = ''
    INFO.DE = ''
    ID.PROC = ID.NEW
    MON.TP = '03'
    REC.CON = ''
    EX.USER = ''
    EX.PC = ''
    REDO.CH.PREV.DBCM.ID = "SYSTEM"

    KEY1 = '123456'

RETURN

********
PROCESS:
********

    Y.CUSTOMER = COMI

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        Y.CUS.STATUS = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
        Y.CUS.TYPE = R.CUSTOMER<EB.CUS.LOCAL.REF><1,L.CU.TIPO.CL.POS>
        Y.EMAIL.REG = R.CUSTOMER<EB.CUS.EMAIL.1>

        Y.ACTDATAOS = Y.CUSTOMER:'*':'ACTDATOS'
        Y.TELEFONOS = Y.CUSTOMER:'*':'TELEFONOS'
        CALL F.READ(FN.CUST.DOCUMENT,Y.ACTDATAOS,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
        Y.ACTDATAOS.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>

        IF Y.ACTDATAOS.STATUS NE '1' AND Y.ACTDATAOS.STATUS NE '' THEN
            GOSUB GET.ACTDATOS.DESC
            ETEXT = 'EB-REDO.CH.V.DOC':@FM:Y.ACTDATOS.DESC
            CALL STORE.END.ERROR
        END


    END

    IF Y.CUS.STATUS NE 1 THEN
        GOSUB GET.DESC.STATUS
        ETEXT = 'EB-REDO.CH.V.EMAIL':@FM:Y.CUS.STATUS.DESC
        CALL STORE.END.ERROR
        RETURN
    END

    IF PGM.VERSION EQ ',REDO.PERS.NEWINT' THEN
        SEL.CMD = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':Y.CUSTOMER:' AND CHANNEL EQ INTERNET AND PROD.USED EQ PERSONAL'
        GOSUB CHECK.IF.USER.EX
    END

    IF PGM.VERSION EQ ',REDO.PERS.NEWTEL' THEN
        SEL.CMD = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':Y.CUSTOMER:' AND CHANNEL EQ TELEFONO AND PROD.USED EQ PERSONAL.TEL'
        GOSUB CHECK.IF.USER.EX
    END

    IF Y.CUS.TYPE EQ 'PERSONA JURIDICA' OR Y.CUS.TYPE EQ 'CLIENTE MENOR' THEN
        ETEXT = 'EB-REDO.CH.V.EMAIL2':@FM:Y.CUS.TYPE
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.EMAIL.REG EQ '' AND PGM.VERSION NE ',REDO.PERS.NEWTEL' THEN
        ETEXT = 'EB-REDO.NOT.MAIL'
        CALL STORE.END.ERROR
        RETURN
    END

* Commented for PACS00462053 [DUPLICATION MAIL GENERATION]

* IF PGM.VERSION NE ',REDO.PERS.NEWTEL' THEN
* GOSUB CHECK.PREV
* END


    IF PGM.VERSION NE ',REDO.PERS.NEWTEL' AND SENDMAIL EQ 0 THEN
        SENDMAIL = 'N'
    END

    IF PGM.VERSION EQ ',REDO.PERS.NEWTEL' AND SHOWPIN EQ 0 THEN
        SHOWPIN = 'N'
    END

RETURN

******************
GET.ACTDATOS.DESC:
******************

    R.DOCUMENT.STATUS = '' ; DS.ERR = ''
    CALL F.READ(FN.DOCUMENT.STATUS,Y.ACTDATAOS.STATUS,R.DOCUMENT.STATUS,F.DOCUMENT.STATUS,DS.ERR)
    IF R.DOCUMENT.STATUS THEN
        IF Y.ACTDATAOS.STATUS NE 2 THEN
            Y.ACTDATOS.DESC2 = ''
        END ELSE
            Y.ACTDATOS.DESC2 = ' (ILOCALIZABLE)'
        END
        Y.ACTDATOS.DESC = R.DOCUMENT.STATUS<DOC.STAT.DESCRIPTION>
        IF LNGG EQ 1 THEN
            Y.ACTDATOS.DESC = FIELD(Y.ACTDATOS.DESC,@VM,1)
        END ELSE
            Y.ACTDATOS.DESC = FIELD(Y.ACTDATOS.DESC,@VM,2)
        END
        Y.ACTDATOS.DESC = Y.ACTDATOS.DESC:Y.ACTDATOS.DESC2
    END

RETURN

****************
GET.DESC.STATUS:
****************

    R.CUSTOMER.STATUS = '' ; CS.ERR = ''
    CALL F.READ(FN.CUSTOMER.STATUS,Y.CUS.STATUS,R.CUSTOMER.STATUS,F.CUSTOMER.STATUS,CS.ERR)
    IF R.CUSTOMER.STATUS THEN
        Y.CUS.STATUS.DESC = R.CUSTOMER.STATUS<EB.CST.SHORT.NAME>
    END

RETURN

*****************
CHECK.IF.USER.EX:
*****************

    SEL.CMD.ERR = ''
    CALL EB.READLIST(SEL.CMD,SEL.CMD.LIST,'',Y.SEL.CMD.LIST.NO,SEL.CMD.ERR)

    IF Y.SEL.CMD.LIST.NO GE 1 THEN
        ETEXT = 'EB-REDO.CH.V.EMAIL3'
        CALL STORE.END.ERROR
        RETURN
    END

RETURN

***********
CHECK.PREV:
***********

    CALL CACHE.READ(FN.REDO.CH.PREV.DBCM,REDO.CH.PREV.DBCM.ID,R.REDO.CH.PREV.DBCM,ERR.REDO.CH.PREV.DBCM)

    IPADD.DESC = R.REDO.CH.PREV.DBCM<REDO.PREV.IP.ADD>
    PORT.DESC = R.REDO.CH.PREV.DBCM<REDO.PREV.PORT>
    SIDSERV.DESC = R.REDO.CH.PREV.DBCM<REDO.PREV.SIDSERV>
    USER.DESC = DECRYPT(R.REDO.CH.PREV.DBCM<REDO.PREV.DB.USER>,KEY1,JBASE_CRYPT_DES_BASE64)
    PWD.DESC = DECRYPT(R.REDO.CH.PREV.DBCM<REDO.PREV.DB.PWD>,KEY1,JBASE_CRYPT_DES_BASE64)
    MSG = R.REDO.CH.PREV.DBCM<REDO.PREV.MSG.IF.DB.ER>

    ALLPARAM = IPADD.DESC:",":PORT.DESC:",":SIDSERV.DESC:",":USER.DESC:",":PWD.DESC:",":MSG

    className = "com.temenos.redo.Prevcheck"
    methodName = "searchPrev"

    CALLJ className,methodName, ALLPARAM SETTING ret ON ERROR
        GOSUB ERROR.HANDLER
    END

    IF ret NE 1 THEN
        CALL APAP.REDOCHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,MSG,REC.CON,EX.USER,EX.PC) ;*Manual R22 conversion
        ETEXT = MSG
        CALL STORE.END.ERROR
        RETURN
    END

RETURN

**************
ERROR.HANDLER:
**************

    ERR = SYSTEM(0)
    BEGIN CASE
        CASE ERR EQ 1
            YTEXT1 = "Error fatal al crear el hilo!"
        CASE ERR EQ 2
            YTEXT1 = "No se puede encontrar JVM.dll!"
        CASE ERR EQ 3
            YTEXT1 = "Clase ": className :" no existe!"
        CASE ERR EQ 4
            YTEXT1 = "Error de conversion UNICODE!"
        CASE ERR EQ 5
            YTEXT1 = "Metodo ": methodName : " no existe!"
        CASE ERR EQ 6
            YTEXT1 = "No se puede encontrar objeto Constructor!"
        CASE ERR EQ 7
            YTEXT1 = "No se puede instanciar objecto!"
        CASE @TRUE
            YTEXT1 = "Error desconocido!"
    END CASE

    CALL APAP.REDOCHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,YTEXT1,REC.CON,EX.USER,EX.PC) ;*Manual R22 conversion

RETURN

END
