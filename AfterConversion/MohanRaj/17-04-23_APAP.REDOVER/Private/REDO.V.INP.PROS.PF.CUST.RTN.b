* @ValidationCode : MjotMTI4MDg1OTMzNjpDcDEyNTI6MTY4MTczNTc4MDQwMzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 18:19:40
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
SUBROUTINE REDO.V.INP.PROS.PF.CUST.RTN
*******************************************************************************************************************
*Company   Name    : Asociaciopular de Ahorros y Pramos Bank
*Developed By      : P.ANAND(anandp@temenos.com)
*Date              : 26.10.2009
*Program   Name    : REDO.V.INP.CUST.RTN
*------------------------------------------------------------------------------------------------------------------
*Description       : This subroutine validates the customer's age and check whether the customer is major or a minor
*Linked With       : This routine has to be attached as an input routine to the versions of fisica customer prospect version
*In  Parameter     : -NA-
*Out Parameter     : -NA-
*-----------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Date                   Name                   Reference               Version
* -------                ----                   ----------              --------
* 29/10/2009           R.Ganesh               ODR-2009-10-0807         Initial Version
* 13/01/2011         J.Riyas Ahamad Basha       HD1052468              MODIFY (LINE: 127 AND 134)
* 09-MAR-2010        Prabhu N                   HD1053255              Line 128 Modified,Age checking added for Persona Fisica also
* 23-MAY-2011        Marimuthu S                PACS00060200           Line 132 Modified
* 27-OCT-2011        Pradeep S                  PACS00152066           Age validation changed
* 21-NOV-2011        S.SUDHARSANAN              PACS00157018           Raise the override message if padrone interface is down
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_GTS.COMMON
    $INSERT I_REDO.V.VAL.CED.IDENT.COMMON
    $INSERT JBC.h
*------------------------------------------------------------------------------------------------------------------
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*-------------------------------------------------------------------------------------------------------------------
INIT:
******
* This block initialise the local fields and variables used
    Y.PGM.VERSION = PGM.VERSION
    FLAG = 1  ; FLAG.ACT = 1 ; FLAG.NOUN = 1 ; FLAG.LEGAL = 1 ;FLAG.OVERRIDE = ''
    LREF.FIELDS = 'L.CU.CIDENT':@VM:'L.CU.NOUNICO':@VM:'L.CU.RNC':@VM:'L.CU.ACTANAC':@VM:'L.CU.AGE':@VM:'L.CU.TIPO.CL'
    Y.LREF.POS = ''
    CALL MULTI.GET.LOC.REF('CUSTOMER',LREF.FIELDS,Y.LREF.POS)
    Y.L.CU.CIDENT.POS = Y.LREF.POS<1,1>
    Y.L.CU.NOUNICO.POS = Y.LREF.POS<1,2>
    Y.L.CU.RNC.POS = Y.LREF.POS<1,3>
    Y.L.CU.ACTANAC.POS = Y.LREF.POS<1,4>
    Y.L.CU.AGE.POS = Y.LREF.POS<1,5>
    Y.L.CU.TIPO.CL.POS = Y.LREF.POS<1,6>
    Y.L.CU.CIDENT = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.CIDENT.POS>
    Y.L.CU.NOUNICO = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.NOUNICO.POS>
    Y.L.CU.RNC = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.RNC.POS>
    Y.L.CU.ACTANAC = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.ACTANAC.POS>
    Y.LEGAL.ID = R.NEW(EB.CUS.LEGAL.ID)<1,1>
    VAR.TIPO.CL = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.TIPO.CL.POS>
    Y.NATIONALITY = R.NEW(EB.CUS.NATIONALITY)
RETURN
*-------------------------------------------------------------------------------------------------------------------
OPEN.FILES:
***********
* This block open the CUSTOMER file
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
RETURN
*-------------------------------------------------------------------------------------------------------------------
PROCESS:
********
* This block checks the Y.PGM.VERSION and executes the corresponding sub blocks
    GOSUB CHK.AGE
    GOSUB CHK.LOC.FIELDS
    GOSUB CHECK.OVERRIDE
RETURN
*-------------------------------------------------------------------------------------------------------------------
CHK.AGE:
********
* This block checks the current age of customer.If the age of the customer extracted is less than 14, then extract the value of
* the field RELATION.CODE and If this value is not 13, then set the error variable ETEXT to EB-REDO.TUTOR
* If the age of the customer is more than or equal to 18 years of age, then check field L.CU.TIPO.CL value is equal to "CLIENTE MENOR"
* and if it is then set the error variable, ETEXT to EB-REDO.NO.ES.MENOR

    Y.L.CU.AGE = R.NEW(EB.CUS.LOCAL.REF)<1,Y.L.CU.AGE.POS>
    Y.RELATION.CODE = R.NEW(EB.CUS.RELATION.CODE)

**PACS00060200**-START
*IF Y.L.CU.AGE LE '14' THEN
    IF Y.L.CU.AGE LT '14' THEN  ;* PACS00152066 - S/E
**PACS00060200**-END
        CHANGE @VM TO @FM IN Y.RELATION.CODE
        LOCATE '13' IN Y.RELATION.CODE SETTING TUT.POS ELSE
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.AGE.POS
            ETEXT = 'EB-REDO.TUTOR'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
    IF Y.L.CU.AGE AND VAR.TIPO.CL THEN
        IF Y.L.CU.AGE GE '18' AND VAR.TIPO.CL EQ 'CLIENTE MENOR' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.TIPO.CL.POS
            ETEXT = 'EB-REDO.NO.ES.MENOR'
            CALL STORE.END.ERROR
            FLAG = ''
        END
        IF Y.L.CU.AGE LT '18' AND VAR.TIPO.CL EQ 'PERSONA FISICA' THEN
            AF=EB.CUS.LOCAL.REF
            AV = Y.L.CU.TIPO.CL.POS
            ETEXT = 'EB-REDO.NO.ES.MAJOR'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------
CHK.LOC.FIELDS:
***************
* This block gets value of local ref fields L.CU.CIDENT,L.CU.NOUNICO,L.CU.RNC,L.CU.ACTANAC and core field LEGAL.ID
* If all above fields are null,then set ETEXT as 'EB-REDO.DOC.NO.INGRESADO'
* In all the rest of the cases, check whether the particular value is having a value
* If that field has a value,then check other fields have a value
* and if yes, then set the ETEXT to EB-REDO.DOC.MULTIPLE
* and if NATIONALITY is 'DO' and LEGAL.ID has value,then set ETEXT as EB-REDO.INVALID.DOC

    IF Y.L.CU.CIDENT EQ '' AND Y.L.CU.NOUNICO EQ '' AND Y.L.CU.ACTANAC EQ '' AND Y.LEGAL.ID EQ '' THEN
        Y.NATIONALITY = R.NEW(EB.CUS.NATIONALITY)
        IF Y.NATIONALITY EQ 'DO' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.CIDENT.POS
        END ELSE
            AF = EB.CUS.LEGAL.ID
            AV = 1
        END
        ETEXT = 'EB-REDO.DOC.NO.INGRESADO'
        CALL STORE.END.ERROR
        FLAG = ''
    END
    GOSUB CHK.MULTIDOC
    GOSUB CHK.LEGAL
    GOSUB CHK.CIDENT
RETURN
*----------------------------------------------------------------------------------------------------------------------
CHK.MULTIDOC:
*-----------------------------------------------------------------------------------------------------------------------
    IF Y.L.CU.CIDENT NE '' THEN
        IF Y.L.CU.NOUNICO NE '' OR Y.L.CU.RNC NE '' OR Y.L.CU.ACTANAC NE '' OR Y.LEGAL.ID NE '' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.CIDENT.POS
            ETEXT = 'EB-REDO.DOC.MULTIPLE'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
    IF Y.L.CU.NOUNICO NE '' THEN
        IF Y.L.CU.CIDENT NE '' OR Y.L.CU.RNC NE '' OR Y.L.CU.ACTANAC NE '' OR Y.LEGAL.ID NE '' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.NOUNICO.POS
            ETEXT = 'EB-REDO.DOC.MULTIPLE'
            CALL STORE.END.ERROR
            FLAG = ''
            FLAG.NOUN = ''
        END
    END
    IF Y.L.CU.RNC NE '' THEN
        IF Y.L.CU.CIDENT NE '' OR Y.L.CU.NOUNICO NE '' OR Y.L.CU.ACTANAC NE '' OR Y.LEGAL.ID NE '' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.RNC.POS
            ETEXT = 'EB-REDO.DOC.MULTIPLE'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
    IF Y.L.CU.ACTANAC NE '' THEN
        IF Y.L.CU.CIDENT NE '' OR Y.L.CU.NOUNICO NE '' OR Y.L.CU.RNC NE '' OR Y.LEGAL.ID NE '' THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.ACTANAC.POS
            ETEXT = 'EB-REDO.DOC.MULTIPLE'
            CALL STORE.END.ERROR
            FLAG = ''
            FLAG.ACT = ''
        END
    END
    IF Y.LEGAL.ID NE '' THEN
        IF Y.L.CU.CIDENT NE '' OR Y.L.CU.NOUNICO NE '' OR Y.L.CU.RNC NE '' OR Y.L.CU.ACTANAC NE '' THEN
            AF = EB.CUS.LEGAL.ID
            AV = 1
            ETEXT = 'EB-REDO.DOC.MULTIPLE'
            CALL STORE.END.ERROR
            FLAG = ''
            FLAG.LEGAL = ''
        END
    END
RETURN
*---------------------------------------------------------------------------------------------------------------------------
CHK.LEGAL:
*---------------------------------------------------------------------------------------------------------------------------
    IF Y.NATIONALITY EQ 'DO' AND Y.LEGAL.ID NE '' AND FLAG.LEGAL EQ 1 THEN
        AF = EB.CUS.LEGAL.ID
        AV = 1
        ETEXT = 'EB-REDO.INVALID.DOC'
        CALL STORE.END.ERROR
        FLAG = ''
    END ELSE
        Y.FOR.PASS=ISALNUM(Y.LEGAL.ID)
        IF NOT(Y.FOR.PASS) AND Y.LEGAL.ID THEN
            AF = EB.CUS.LEGAL.ID
            AV = 1
            ETEXT = 'EB-REDO.INVALID.PASS'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
RETURN
*---------------------------------------------------------------------------------------------------
CHK.CIDENT:
*---------------------------------------------------------------------------------------------------
    IF VAR.TIPO.CL EQ 'PERSONA FISICA' AND Y.NATIONALITY EQ 'DO' AND NOT(Y.L.CU.CIDENT) THEN
        IF Y.L.CU.NOUNICO NE '' AND FLAG.NOUN EQ 1 THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.NOUNICO.POS
            ETEXT = 'EB-REDO.INVALID.DOC'
            CALL STORE.END.ERROR
            FLAG = ''
        END
        IF Y.L.CU.ACTANAC NE '' AND FLAG.ACT EQ 1 THEN
            AF = EB.CUS.LOCAL.REF
            AV = Y.L.CU.ACTANAC.POS
            ETEXT = 'EB-REDO.INVALID.DOC'
            CALL STORE.END.ERROR
            FLAG = ''
        END
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------
CHECK.OVERRIDE:
*----------------------------------------------------------------------------------------------------------------------
    IF FLAG EQ 1 AND NOT(OFS.VAL.ONLY) AND OFS$OPERATION EQ 'PROCESS' THEN
        IF Y.L.CU.CIDENT THEN
            Cedule = "padrone$":Y.L.CU.CIDENT
            INT.CODE = 'CIDENT'
            GOSUB CHK.PADRONE
            IF FLAG.OVERRIDE EQ 1 AND VAR.TIPO.CL NE 'PERSONA JURIDICA' THEN
                TEXT = "REPO.PADR.PF"
                CURR.NO = DCOUNT(R.NEW(EB.CUS.OVERRIDE),@VM)+1
                CALL STORE.OVERRIDE(CURR.NO)
            END
        END
        IF Y.L.CU.RNC THEN
            Cedule = "rnc$":Y.L.CU.RNC
            INT.CODE = 'RNC'
            GOSUB CHK.PADRONE
            IF FLAG.OVERRIDE EQ 1 AND VAR.TIPO.CL EQ 'PERSONA JURIDICA' THEN
                TEXT = "REPO.PADR.PJ"
                CURR.NO = DCOUNT(R.NEW(EB.CUS.OVERRIDE),@VM)+1
                CALL STORE.OVERRIDE(CURR.NO)
            END
        END
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------
CHK.PADRONE:
*--------------------------------------------------------------------------------------------------------------------
*Raising override if the given value is not availble in padrone interface
    Param1 = "com.padrone.ws.util.MainClass"
    Param2 = "callPadrone"
    Param3 = Cedule
    Ret = ""
    ACTIVATION = "APAP_PADRONES_WEBSERVICES"
    INPUT_PARAM=Cedule
    ERROR.CODE = CALLJEE(ACTIVATION,INPUT_PARAM)
*PACS00157018 - S
    IF ERROR.CODE THEN
*TEXT = "REDO.CHECK.PADRONE"
*CURR.NO = DCOUNT(R.NEW(EB.CUS.OVERRIDE),VM)+1
*CALL STORE.OVERRIDE(CURR.NO)
*ETEXT= "FAIL@FM":ERROR.CODE
*CALL STORE.END.ERROR
    END ELSE
        Ret=INPUT_PARAM
    END
*PACS00157018 - E
    VAR.NAME = Ret
    INT.TYPE = 'ONLINE'
    BAT.NO = ''
    BAT.TOT = ''
    INFO.OR = ''
    INFO.DE = ''
    ID.PROC = ''
    MON.TP = ''
    DESC = ''
    REC.CON = ''
    EX.USER = ''
    EX.PC = ''
    CHANGE '::' TO @FM IN VAR.NAME
    REC.CON = VAR.NAME<2>
    DESC = VAR.NAME<3>
    IF Ret THEN
        GOSUB PADRONE.CHECK
    END
RETURN
*--------------------------------------------------------------------------------------------------------------------
PADRONE.CHECK:
*--------------------------------------------------------------------------------------------------------------------
    CHANGE '$' TO '' IN VAR.NAME
    CHANGE '#' TO @FM IN VAR.NAME
    VAL.NAME = VAR.NAME<1>
    CHANGE ':' TO @FM IN VAL.NAME
    IF VAL.NAME<1> EQ 'SUCCESS' ELSE
        IF VAL.NAME<1> EQ 'FAILURE' THEN
            GOSUB FAIL.PADRONE
        END
    END
RETURN
*--------------------------------------------------------------------------------------------------------------------
FAIL.PADRONE:
*------------------------------------------------------------------------------------------------------------------------

    CHECK.FAIL.MSG  = VAR.NAME<2>
    CHECK.ERROR.CODE = FIELD(CHECK.FAIL.MSG,'-',1)
    ERROR.CODE.VALUE = TRIM(FIELD(CHECK.ERROR.CODE,':',2), "", 'A')
    IF ERROR.CODE.VALUE EQ '019' THEN
        TEXT = "REDO.CHECK.PADRONE"
        CURR.NO = DCOUNT(R.NEW(EB.CUS.OVERRIDE),@VM)+1
        CALL STORE.OVERRIDE(CURR.NO)

        MON.TP = '08'
        DESC = 'El webservices no esta disponible'
        CALL APAP.CHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC) ;* R22 Manual Conversion - CALL method format modified

    END ELSE
        FLAG.OVERRIDE = 1
        MON.TP = '04'
        CALL APAP.CHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC) ;* R22 Manual Conversion - CALL method format modified
    END
RETURN
*-------------------------------------------END OF RECORD---------------------------------------------------------
END
