* @ValidationCode : MjotNjQ0MTU1MDkyOkNwMTI1MjoxNjgxODg4MDQzMjA1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:37:23
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
SUBROUTINE REDO.V.VAL.CUEN.CLIE
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.CUEN.CLIE
* Attached as     : ROUTINE
* Primary Purpose : Verify the account correspond the customer selected
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.ACCOUNT
*Tus Start
    $INSERT I_F.EB.CONTRACT.BALANCES
*Tus End

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
*Get information of cusrtomer and arrangement
    VAR.CUSTOMER = R.NEW(COLL.LOCAL.REF)<1,WPOS.CUSTOMER>
    VAR.CREDIT   = R.NEW(COLL.LOCAL.REF)<1,WPOS.ACCOUNT>

**GET INFORMATION FOR ACCOUNTS**
    SELECT.STATEMENT = 'SELECT ':FN.ACCOUNT:' WITH CUSTOMER EQ ':VAR.CUSTOMER: ' AND ACCOUNT.NUMBER EQ ': VAR.CREDIT
    LOCK.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    Y.ID.AA.PRD = ''
    CALL EB.READLIST(SELECT.STATEMENT,LOCK.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

*Get the data thar view in the list
    LOOP
        REMOVE Y.ID.AA.PRD FROM LOCK.LIST SETTING POS
    WHILE Y.ID.AA.PRD:POS

        CALL CACHE.READ(FN.ACCOUNT, Y.ID.AA.PRD, R.ACCOUNT, Y.ERR)
        R.ECB= '' ; ECB.ERR= '' ;*Tus Start
        CALL EB.READ.HVT("EB.CONTRACT.BALANCES",Y.ID.AA.PRD,R.ECB,ECB.ERR);*Tus End

*GET THE AMONUT AND LOCKED
        VAR.BLOQUEO = R.ACCOUNT<AC.LOCKED.AMOUNT>
*  VAR.MONTO   = R.ACCOUNT<AC.WORKING.BALANCE>;*Tus Start
        VAR.MONTO   = R.ECB<ECB.WORKING.BALANCE>;*Tus End
        VAR.CONT += 1
        IF Y.ERR NE '' THEN
            P.MESSAGE = 'ST-REDO.COLLA.ERR.LEE.LOCK'
            RETURN
        END
    REPEAT

*Show an override if the account and customer not find
    IF VAR.CONT EQ 0 THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,2>
        ETEXT = 'ST-COLL.VER.CLIE.CUEN'
        CALL STORE.END.ERROR
    END

RETURN
*----------------------------------------------------------------------------

INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.ACCOUNT   = 'F.ACCOUNT'
    F.ACCOUNT    = ''
    R.ACCOUNT    = ''

*Initialice vars
    VAR.CUSTOMER = ''
    VAR.CREDIT   = ''
    VAR.CONT     = 0
    WCAMPO       = ''

*Set the local fild for read
    WCAMPO     = "L.COL.SEC.HOLD"
    WCAMPO<2>  = "L.COL.NUM.INSTR"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOS.CUSTOMER  = YPOS<1,1>
    WPOS.ACCOUNT   = YPOS<1,2>

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*------------
END
