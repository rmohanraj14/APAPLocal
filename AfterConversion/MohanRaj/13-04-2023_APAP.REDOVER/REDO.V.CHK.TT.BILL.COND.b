* @ValidationCode : MjoyNDU1ODA2NjY6Q3AxMjUyOjE2ODEzOTEwNzkyNzA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:34:39
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
SUBROUTINE REDO.V.CHK.TT.BILL.COND
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.V.CHK.TT.BILL.COND
*--------------------------------------------------------------------------------------------------------
*Description  : This is a check record routine to check and default the Bill details in local fields
*In Parameter : N/A
*Out Parameter: N/A
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
*  06Apr2011       Pradeep S            PACS00052995            Initial Creation
*  21 JUL 2011     J.Costa C.           PACS00052995            Fix BILL.TYPE and BILL.COND fields information issue.
*  26 Feb 2013     Riyas                PACS00251875            Company Name updated
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     CONVERT TO CHANGE,FM TO @FM,VM TO @VM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.USER
*
    $INSERT I_F.REDO.THIRDPRTY.PARAMETER
*
    GOSUB INIT
    GOSUB PROCESS
*
RETURN
*
*======
INIT:
*=====

    FN.REDO.THRDPTY.COMP = 'F.REDO.THIRDPRTY.PARAMETER'
    F.REDO.THRDPTY.COMP = ''

    WCAMPO    = "L.TT.BILL.COND"
    WCAMPO<2> = "L.TT.BILL.TYPE"
    WCAMPO<3> = "L.TT.CMPNY.NAME"
    WCAMPO    = CHANGE(WCAMPO,@FM,@VM)
    CALL MULTI.GET.LOC.REF("TELLER",WCAMPO,YPOS)
    WPOS.BCOND   = YPOS<1,1>
    WPOS.BTYPE   = YPOS<1,2>
    WPOS.CNAME   = YPOS<1,3>

    WLANG = R.USER<EB.USE.LANGUAGE>

RETURN

*========
PROCESS:
*=======
*
    Y.COMP.ID = COMI
*
    R.THRD.COM = ''
    CALL F.READ(FN.REDO.THRDPTY.COMP,Y.COMP.ID,R.THRD.COM,F.REDO.THRDPTY.COMP,ERR)

    IF R.THRD.COM THEN

        Y.BILL.COND = R.THRD.COM<REDO.TP.BILL.COND>
        VAR.VIRTUAL.TABLE = 'BILL.COND'
        GOSUB BILL.COND.PROCESS
        R.NEW(TT.TE.LOCAL.REF)<1,WPOS.BCOND> = Y.BILL.COND.VAL

        Y.BILL.COND = R.THRD.COM<REDO.TP.BILL.TYPE>
        VAR.VIRTUAL.TABLE = 'BILL.TYPE'
        GOSUB BILL.COND.PROCESS
        R.NEW(TT.TE.LOCAL.REF)<1,WPOS.BTYPE> = Y.BILL.COND.VAL

        R.NEW(TT.TE.LOCAL.REF)<1,WPOS.CNAME> = R.THRD.COM<REDO.TP.COMP.NAME>        ;* PACS00251875 - S/E

    END


RETURN

*=================
BILL.COND.PROCESS:
*=================
*

    CHANGE @VM TO @FM IN Y.BILL.COND ;*R22 Auto code conversion
    Y.CNT.VALUES = DCOUNT(Y.BILL.COND,@FM)


    Y.VALUES = Y.BILL.COND
    GOSUB GET.VALUES
    Y.BILL.COND.VAL = Y.BILL.VAL


RETURN


*=====================
GET.VALUES:
*======================

    VIRTUAL.TABLE.IDS = ''
    VIRTUAL.TABLE.VALUES = ''
    Y.BILL.VAL = ''

    CALL EB.LOOKUP.LIST(VAR.VIRTUAL.TABLE)
    CNT.VTABLE= DCOUNT(VAR.VIRTUAL.TABLE,@FM)
    VIRTUAL.TABLE.IDS = VAR.VIRTUAL.TABLE<2>        ;*2nd Part of @ID
    VIRTUAL.TABLE.VALUES = VAR.VIRTUAL.TABLE<CNT.VTABLE>      ;*Description field values
    CHANGE '_' TO @FM IN VIRTUAL.TABLE.VALUES
    CHANGE '_' TO @FM IN VIRTUAL.TABLE.IDS

    CNT =1
    LOOP
    WHILE CNT LE Y.CNT.VALUES
        TABLE.IDS = ''
        TABLE.IDS = Y.VALUES<CNT>
        LOCATE TABLE.IDS IN VIRTUAL.TABLE.IDS SETTING POS THEN
            WDTA.TEST = VIRTUAL.TABLE.VALUES<POS, WLANG>
            IF WDTA.TEST EQ "" THEN
                WDTA.TEST = TABLE.IDS
            END
            Y.BILL.VAL<1,1,-1> = WDTA.TEST
        END
        CNT += 1
    REPEAT

RETURN

END
