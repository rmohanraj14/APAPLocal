* @ValidationCode : Mjo0NDMyNTk3MTA6Q3AxMjUyOjE2ODE4OTA2MzcxNjI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:20:37
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
SUBROUTINE REDO.V.VAL.FIL.CUENTA
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.FIL.CUENTA
* Attached as     : ROUTINE
* Primary Purpose :
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
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM, = to EQ
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

* Get the customer number
    VAR.CUSTOMER = R.NEW(COLL.LOCAL.REF)<1,WPOS.CUSTOMER>
    VAR.TIPO = R.NEW(COLL.COLLATERAL.TYPE)

*///FIX DEPOSITS///
    IF (VAR.TIPO EQ 152) THEN

        SELECT.STATEMENT = 'SELECT FBNK.AZ.ACCOUNT WITH CUSTOMER LIKE ':VAR.CUSTOMER
        LOCK.LIST = ''
        LIST.NAME = ''
        SELECTED = ''
        SYSTEM.RETURN.CODE = ''
        Y.ID.AA.PRD = ''
        CALL EB.READLIST(SELECT.STATEMENT,LOCK.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

*GET ALL VALUES FROM THE LIST AND ADD THE LOCK VALUE
        LOOP
            REMOVE Y.ID.AA.PRD FROM LOCK.LIST SETTING POS
        WHILE Y.ID.AA.PRD:POS

            CALL CACHE.READ(FN.AZ, Y.ID.AA.PRD, R.AZ, Y.ERR)

*GET AMOUNT LOCK FOR ACCOUNT
*VAR.LOCK1    =  R.LOCK1<AC.LCK.LOCKED.AMOUNT>
*IF VAR.LOCK1 = '' THEN
*  VAR.LOCK1 = 0
*END
*VAR.TOT.LOCK = VAR.TOT.LOCK + VAR.LOCK1

            IF Y.ERR NE '' THEN
                P.MESSAGE = "ST-REDO.COLLA.ERR.LEE.LOCK"
                RETURN
            END
        REPEAT

    END

RETURN
*----------------------------------------------------------------------------


INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.ACCOUNT   = 'F.ACCOUNT'
    F.ACCOUNT    = ''
    R.ACCOUNT    = ''

    FN.AZ        = 'F.AZ.ACCOUNT'
    F.AZ         = ''
    R.AZ         = ''


*Read the local fields
    WCAMPO = "L.COL.SEC.HOLD"   ;*Customer

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOS.CUSTOMER  = YPOS<1,1>

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.AZ,F.AZ)
RETURN
*------------
END
