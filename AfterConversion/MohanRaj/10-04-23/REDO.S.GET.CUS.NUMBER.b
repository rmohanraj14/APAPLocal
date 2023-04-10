* @ValidationCode : Mjo5MTMzNzgwMTE6Q3AxMjUyOjE2ODExMjczOTIwMjc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Apr 2023 17:19:52
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.CUS.NUMBER(CUSTOMER.NO)

*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS..
*
* Developed By  : Nava V
* Program Name  : REDO.S.GET.CUS.NUMBER
*----------------------------------------------------------------------------------
* Description   : Deal slip routine attached to TT.FXSN.SLIP to retrieve CUSTOMER number related
*                 in REDO.CUS.IDENTIFICATION application....
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 23-Dec-2011      Nava V.                           Initial creation
* 17-Jun-2012      Nava V.                           Customer number tracking from new tables
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     IF Condition added,FM TO @FM
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FOREX
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
*
    $INSERT I_System
*
    GOSUB INITIAL
    GOSUB OPEN.FILES
    GOSUB GET.LOCAL.REF
    GOSUB PROCESS

RETURN

*----------------------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------------------
*
    FN.CUS.L.CU.RNC = 'F.CUSTOMER.L.CU.RNC'
    F.CUS.L.CU.RNC  = ''
    CALL OPF(FN.CUS.L.CU.RNC,F.CUS.L.CU.RNC)
*
    FN.CUS.L.CU.CIDENT = 'F.CUSTOMER.L.CU.CIDENT'
    F.CUS.L.CU.CIDENT  = ''
    CALL OPF(FN.CUS.L.CU.CIDENT,F.CUS.L.CU.CIDENT)
*
    FN.CUS.LEGAL.ID = 'F.REDO.CUSTOMER.LEGAL.ID'
    F.CUS.LEGAL.ID  = ''
    CALL OPF(FN.CUS.LEGAL.ID,F.CUS.LEGAL.ID)
*
RETURN
*
*----------------------------------------------------------------------------------
GET.LOCAL.REF:
*----------------------------------------------------------------------------------
*
    APPL.ARR = "FOREX":@FM:"FUNDS.TRANSFER":@FM:"TELLER"
    FIELD.ARR = "L.FX.LEGAL.ID":@FM:"L.FT.LEGAL.ID":@FM:"L.TT.LEGAL.ID"
    FIELD.POS = ""
    CALL MULTI.GET.LOC.REF(APPL.ARR,FIELD.ARR,FIELD.POS)
*
    L.FX.LEGAL.ID.POS = FIELD.POS<1,1>
    L.FT.LEGAL.ID.POS = FIELD.POS<2,1>
    L.TT.LEGAL.ID.POS = FIELD.POS<3,1>
*
RETURN
*
*----------------------------------------------------------------------------------
INITIAL:
*----------------------------------------------------------------------------------
*
    Y.TT.LEGAL.ID = ""
    CUSTOMER.IDE  = ""
*
    WCUS.NUM      = ""
    WCVD          = ""
    WCCA          = ""
*
RETURN
*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------
*
    BEGIN CASE
*    CASE APPLICATION EQ 'FOREX'
        CASE ID.NEW[1,2] EQ 'FX'
            Y.FX.LEGAL.ID = R.NEW(FX.LOCAL.REF)<1,L.FX.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN Y.FX.LEGAL.ID
            CUSTOMER.IDE = Y.FX.LEGAL.ID<2>
*    CASE APPLICATION EQ 'FUNDS.TRANSFER'
        CASE ID.NEW[1,2] EQ 'FT'
            Y.FT.LEGAL.ID = R.NEW(FT.LOCAL.REF)<1,L.FT.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN Y.FT.LEGAL.ID
            CUSTOMER.IDE = Y.FT.LEGAL.ID<2>
*    CASE APPLICATION EQ 'TELLER'
        CASE ID.NEW[1,2] EQ 'TT'
            Y.TT.LEGAL.ID = R.NEW(TT.TE.LOCAL.REF)<1,L.TT.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN Y.TT.LEGAL.ID
            CUS.IDENTITY.TYPE = Y.TT.LEGAL.ID<1>
            CUSTOMER.IDE = Y.TT.LEGAL.ID<2>
            GOSUB TYPE.PROOF.CHECK.TT ;* VNL 2011DIC23 - S
    END CASE
    CUSTOMER.NO= FMT(CUSTOMER.NO,'R#14')
*
RETURN
*
*---------
TP.APP.TT:
*---------
*
    CUSTOMER.NO = ''
    BEGIN CASE
        CASE CUS.IDENTITY.TYPE EQ "CEDULA"
            R.CUS.CIDENT = ''
            CALL F.READ(FN.CUS.L.CU.CIDENT,CUSTOMER.IDE,R.CUS.CIDENT,F.CUS.L.CU.CIDENT,CID.ERR)
            CUSTOMER.NO = FIELD(R.CUS.CIDENT,"*",2)
*
        CASE CUS.IDENTITY.TYPE EQ "RNC"
            R.CUS.RNC = ''
            CALL F.READ(FN.CUS.L.CU.RNC,CUSTOMER.IDE,R.CUS.RNC,F.CUS.L.CU.RNC,RNC.ERR)
            CUSTOMER.NO = FIELD(R.CUS.RNC,"*",2)
*
        CASE CUS.IDENTITY.TYPE EQ "PASAPORTE"
            R.CUS.LEGAL = ''
            CALL F.READ(FN.CUS.LEGAL.ID,CUSTOMER.IDE,R.CUS.LEGAL,F.CUS.LEGAL.ID,LEGAL.ERR)
            CUSTOMER.NO = FIELD(R.CUS.LEGAL,"*",2)
*
    END CASE
*
RETURN
*
*----------------------------------------------------------------------------------
TYPE.PROOF.CHECK.TT:
*----------------------------------------------------------------------------------
*
    CALL System.getUserVariables( U.VARNAMES, U.VARVALS )
*
    WWVAR = "CURRENT.VAR.DETAILS" ; YPOS.VAR = ""
    LOCATE WWVAR IN U.VARNAMES SETTING YPOS.VAR THEN
        WCVD = System.getVariable("CURRENT.VAR.DETAILS")
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
            WCVD = ""
        END ;*R22 Auto code conversion-END
        WCUS.NUM = FIELD(WCVD,"*",4)
    END
*
    IF NOT(WCUS.NUM) THEN
        WWVAR = "CURRENT.CLIENTE.APAP" ; YPOS.VAR = ""
        LOCATE WWVAR IN U.VARNAMES SETTING YPOS.VAR THEN
            WCCA = System.getVariable("CURRENT.CLIENTE.APAP")
            IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
                WCCA = ""
            END ;*R22 Auto code conversion-END
            WCUS.NUM = WCCA
        END
    END
*
    IF NOT(WCUS.NUM) THEN
        GOSUB TP.APP.TT
        WCUS.NUM = CUSTOMER.NO
    END
*
    CUSTOMER.NO = WCUS.NUM
*
RETURN
*
END
