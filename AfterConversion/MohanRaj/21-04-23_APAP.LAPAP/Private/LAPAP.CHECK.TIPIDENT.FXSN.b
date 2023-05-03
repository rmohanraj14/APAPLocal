* @ValidationCode : MjoxNDc3ODEwOTc1OkNwMTI1MjoxNjgyMDcwNTE2NTQ5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:18:36
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
$PACKAGE APAP.LAPAP
* Technical report:
* -----------------
* Company Name   : APAP
* Program Name   : LAPAP.CHECK.TIPIDENT.FXSN
* Author         : Raquel P. S.
* Item ID        : CN009180
*-------------------------------------------------------------------------------------
* Description :
* ------------
* This program allow verify the ID against the T24 table (Only cedula and  RNC)
*-------------------------------------------------------------------------------------
* Modification History :
* ----------------------
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2018/03/29     Raquel P. S.        Initial development
*-------------------------------------------------------------------------------------
* Content summary :
* -----------------
* Table name     :
* Auto Increment :
* Views/versions : Versions in REDO.FXSN.TXN.VERSION>SYSTEM for FUNDS.TRANSFER and TELLER
* PGM record      : LAPAP.CHECK.TIPIDENT.FXSN
* DependentRoutines :
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     = TO EQ
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------

SUBROUTINE   LAPAP.CHECK.TIPIDENT.FXSN

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_System
    $INSERT I_F.CUSTOMER
    $INSERT I_F.VERSION
    $INSERT I_F.REDO.ID.CARD.CHECK
    $INSERT I_F.REDO.FXSN.TXN.VERSION
    $INSERT I_REDO.ID.CARD.CHECK.COMMON
    $INSERT I_F.TELLER
*   $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER


**************************************
*OPENING TABLES/ LOADING VARIABLES*
**************************************


    FN.FUNDS.TRANSFER = "F.FUNDS.TRANSFER"
    F.FUNDS.TRANSFER = ""
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.REDO.FXSN.TXN.VERSION = "F.REDO.FXSN.TXN.VERSION"
    F.REDO.FXSN.TXN.VERSION = ""
    CALL OPF(FN.REDO.FXSN.TXN.VERSION,F.REDO.FXSN.TXN.VERSION)

    FN.TELLER = "F.TELLER"
    F.TELLER = ""
    CALL OPF(FN.TELLER,F.TELLER)

    Y.APPLICATION=APPLICATION
    Y.PGM.VERSION=Y.APPLICATION:PGM.VERSION
    Y.L.LEGAL.ID =""
    Y.L.CLNT.TYPE =""
    Y.FLAG = ""


**************************************
* EVALUATING MODULE
**************************************


    IF Y.APPLICATION EQ 'FUNDS.TRANSFER'
    THEN
        Y.L.LEGAL.ID=R.NEW(67)<1,71>
        Y.L.CLNT.TYPE=R.NEW(67)<1,87>
        GOSUB PROCESS.INIT
    END
    ELSE ;*R22 Auto code conversion
        IF Y.APPLICATION EQ 'TELLER'
        THEN
            Y.L.LEGAL.ID=R.NEW(65)<1,106>
            Y.L.CLNT.TYPE=R.NEW(65)<1,119>
            GOSUB PROCESS.INIT
        END
    END

RETURN


*-------------
PROCESS.INIT:
*-------------

    BEGIN CASE
        CASE INDEX(Y.L.LEGAL.ID,"CEDULA",1)
            GOSUB EVAL.CED
        CASE INDEX(Y.L.LEGAL.ID,"PASAPORTE",1)
            GOSUB EVAL.PAS
        CASE INDEX(Y.L.LEGAL.ID,"RNC",1)
            GOSUB EVAL.RNC
    END CASE
RETURN

*-------------
EVAL.CED:
*-------------
    IF  INDEX(Y.L.CLNT.TYPE, "P3",1) OR INDEX(Y.L.CLNT.TYPE, "P4",1) OR INDEX(Y.L.CLNT.TYPE, "P5",1) OR INDEX(Y.L.CLNT.TYPE, "P5",1) OR INDEX(Y.L.CLNT.TYPE, "P6",1)
    THEN
        Y.FLAG= 0
    END ELSE
        Y.FLAG=1
        GOSUB RAISE.ERROR
    END
RETURN

*-------------
EVAL.PAS:
*-------------
    IF INDEX(Y.L.CLNT.TYPE, "P7",1) OR INDEX(Y.L.CLNT.TYPE, "P8",1)
    THEN
        Y.FLAG= 0
    END ELSE
        Y.FLAG=1
        GOSUB RAISE.ERROR
    END
RETURN

*-------------
EVAL.RNC:
*-------------
    IF  INDEX(Y.L.CLNT.TYPE, "E1",1) OR INDEX(Y.L.CLNT.TYPE, "E2",1) OR INDEX(Y.L.CLNT.TYPE, "E3",1)
    THEN
        Y.FLAG= 0
    END ELSE
        Y.FLAG=1
        GOSUB RAISE.ERROR
    END

RETURN

*-------------
RAISE.ERROR:
*-------------
    IF Y.FLAG EQ 1
    THEN
        ETEXT='TIPO CLIENTE NO CORRESPONDE AL TIPO DE DOCUMENTO SELECCIONADO'
        CALL STORE.END.ERROR
    END
RETURN

END
