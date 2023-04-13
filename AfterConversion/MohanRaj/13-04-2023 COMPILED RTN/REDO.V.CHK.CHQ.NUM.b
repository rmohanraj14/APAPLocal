* @ValidationCode : MjotNzYzMzUyOTA4OkNwMTI1MjoxNjgxMzgzMjA5Njk1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:23:29
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
SUBROUTINE REDO.V.CHK.CHQ.NUM
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION :   This routine will be executed at check Record Routine for CHEQUE VERSIONS
*------------------------------------------------------------------------------------------
*
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.CHK.CHQ.NUM
*
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*       DATE            WHO               REFERENCE         DESCRIPTION
*       16.03.2010      SUDHARSANAN S     ODR-2009-10-0319  INITIAL CREATION
*       09.02.2010      SUDHARSANAN S     HD1048577         Update the Account.1 field from Parameter Table
*       21.11.2011      JCOSTA C.                           USE PARAMETER TABLE
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
*
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.TRANSACTION
*
    $INSERT I_F.CERTIFIED.CHEQUE.STOCK
    $INSERT I_F.CERTIFIED.CHEQUE.PARAMETER
*
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*

*-----------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------
*
*       GET the next available cheque no
*


*    Y.CONTENT                          = SEL.LIST<1>
*    R.NEW(TT.TE.LOCAL.REF)<1,CHEQ.POS> = Y.CONTENT
*
*    IF WCHEQUE.TYPE EQ 'NON.GOVT' THEN
*        R.NEW(TT.TE.CHEQUE.NUMBER) = Y.CONTENT
*    END
*
RETURN
*
*----------------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------------
*
    PROCESS.GOAHEAD = "1"
*
    WAPP.LST  = "TELLER" : @FM : "TELLER.TRANSACTION"
    WCAMPO    = "CERT.CHEQUE.NO"
    WCAMPO    = CHANGE(WCAMPO,@FM,@VM)
    WFLD.LST  = WCAMPO
    WCAMPO    = "L.TT.GOV.TYPE"
    WCAMPO    = CHANGE(WCAMPO,@FM,@VM)
    WFLD.LST := @FM : WCAMPO
    CALL MULTI.GET.LOC.REF(WAPP.LST,WFLD.LST,YPOS)
    CHEQ.POS  = YPOS<1,1>
*
    GOV.POS   = YPOS<2,1>
*
    FN.CERTIFIED.CHEQUE.STOCK='F.CERTIFIED.CHEQUE.STOCK'
    F.CERTIFIED.CHEQUE.STOCK=''
*
    FN.CERTIFIED.CHEQUE.PARAMETER='F.CERTIFIED.CHEQUE.PARAMETER'
    F.CERTIFIED.CHEQUE.PARAMETER =''
*
    FN.TELLER.TRANSACTION = "F.TELLER.TRANSACTION"
    F.TELLER.TRANSACTION  = ""
*
    CURR.NO = R.NEW(TT.TE.CURR.NO)
    TT.CODE = R.NEW(TT.TE.TRANSACTION.CODE)
*
RETURN
*
OPEN.FILES:
*
    CALL OPF(FN.CERTIFIED.CHEQUE.STOCK,F.CERTIFIED.CHEQUE.STOCK)
    CALL OPF(FN.CERTIFIED.CHEQUE.PARAMETER,F.CERTIFIED.CHEQUE.PARAMETER)
    CALL OPF(FN.TELLER.TRANSACTION,F.TELLER.TRANSACTION)
*
RETURN
*
*-----------------------
CHECK.PRELIM.CONDITIONS:
*-----------------------
    LOOP.CNT  = 1   ;   MAX.LOOPS = 3
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
                CALL CACHE.READ(FN.TELLER.TRANSACTION,TT.CODE,R.TELLER.TRANSACTION,TT.ERR)
                IF NOT(R.TELLER.TRANSACTION) THEN
                    E               = "EB-TELLER.TRANSACTION.&.NOT.DEFINED":@FM:TT.CODE
                    PROCESS.GOAHEAD = ""
                END ELSE
                    WCHEQUE.TYPE = R.TELLER.TRANSACTION<TT.TR.LOCAL.REF,GOV.POS>
                    IF NOT(WCHEQUE.TYPE) THEN
                        E               = "EB-CHEQUE.TYPE.&.NOT.DEFINED":@FM:WCHEQUE.TYPE
                        PROCESS.GOAHEAD = ""
                    END
                END
            CASE LOOP.CNT EQ 2
                CALL CACHE.READ(FN.CERTIFIED.CHEQUE.PARAMETER,ID.COMPANY,R.CERT.CHEQ.PARAM,CHEQ.ERR)
                TYPE.VALUE    = R.CERT.CHEQ.PARAM<CERT.CHEQ.TYPE>
                ACCOUNT.VALUE = R.CERT.CHEQ.PARAM<CERT.CHEQ.ACCOUNT.NO>
                CHANGE @VM TO @FM IN TYPE.VALUE
                CHANGE @VM TO @FM IN ACCOUNT.VALUE
                LOCATE WCHEQUE.TYPE IN TYPE.VALUE SETTING POS THEN
                    WSERIAL.START          = R.CERT.CHEQ.PARAM<CERT.CHEQ.START.SERIAL.NO,POS>
                END ELSE
                    E               = "EB-CHEQUE.TYPE.&.NOT.DEFINED":@FM:WCHEQUE.TYPE
                    PROCESS.GOAHEAD = ""
                END

            CASE LOOP.CNT EQ 3
                SEL.CMD  = 'SSELECT ':FN.CERTIFIED.CHEQUE.STOCK
                SEL.CMD := ' WITH STATUS EQ AVAILABLE AND @ID LIKE ' : WSERIAL.START : '...'
                CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR)
                IF NOT(SEL.LIST) THEN
                    E               = 'EB-REDO.NO.AVAIL.CHEQUE'
                    PROCESS.GOAHEAD = ""
                END

        END CASE
*
*       Increase
*
        LOOP.CNT += 1
*
    REPEAT
*
RETURN
*

END
