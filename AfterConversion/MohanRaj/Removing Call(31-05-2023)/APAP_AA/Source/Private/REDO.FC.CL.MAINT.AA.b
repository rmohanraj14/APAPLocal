* @ValidationCode : MjotMTk2MjMyMDUzOkNwMTI1MjoxNjgwMTg0NjczNDE1OklUU1M6LTE6LTE6NTIyOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 522
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.CL.MAINT.AA
*
* ====================================================================================
*
*
* ====================================================================================
*
* Subroutine Type :ROUTINE
* Attached to :
* Attached as :
* Primary Purpose :Registra un nuevo record en la tabla REDO.FC.CL.BALANCE con las nuevas garantias
*
* Incoming:
* ---------
*
*
*
* Outgoing:

* ---------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by : Bryan Torres (btorresalbornoz@temenos.com) - TAM Latin America
* Date : Junio 19 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and => to GE, = to EQ
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION           NO CHANGES
*
*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.FC.LIMIT.AA
    $INSERT I_F.REDO.FC.CL.BALANCE

    $INSERT I_F.CREATE.AA
    $INSERT I_F.COLLATERAL
    $INSERT I_REDO.FC.COMMON
*
*************************************************************************
*

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

*
RETURN
*
* ======
PROCESS:
* ======

    GOSUB FIRST


RETURN

* ======
FIRST:
* ======
    CREATE.ARRANGEMENT.AMOUNT.U = CREATE.ARRANGEMENT.AMOUNT

    Y.COUNT = DCOUNT(CREATE.ARRANGEMENT.SD,@VM)
    FOR Y.I = 1 TO Y.COUNT

        IF CREATE.ARRANGEMENT.SD<1,Y.I> GE CREATE.ARRANGEMENT.AMOUNT.U THEN

            MG.ACTUAL<1,Y.I> = CREATE.ARRANGEMENT.AMOUNT.U
            SALDO.DIS<1,Y.I> = CREATE.ARRANGEMENT.SD<1,Y.I> - CREATE.ARRANGEMENT.AMOUNT.U
            GOSUB REGISTRA

            GOSUB UPDATE.COLLATERAL

            RETURN

        END ELSE

            CREATE.ARRANGEMENT.AMOUNT.U = CREATE.ARRANGEMENT.AMOUNT.U - CREATE.ARRANGEMENT.SD<1,Y.I>
            MG.ACTUAL<1,Y.I> = CREATE.ARRANGEMENT.SD<1,Y.I>
            SALDO.DIS<1,Y.I> = CREATE.ARRANGEMENT.SD<1,Y.I> - MG.ACTUAL<1,Y.I>


        END


    NEXT Y.I

RETURN
* ======
REGISTRA:
* ======

    Y.COUNT.SD = DCOUNT(CREATE.ARRANGEMENT.COLL.RIGHT,@VM)
    FOR Y.I.SD = 1 TO Y.COUNT.SD
        IF MG.ACTUAL<1,Y.I.SD> EQ "" THEN
            MG.ACTUAL<1,Y.I.SD> = "0"
        END

    NEXT Y.I.SD

    CALL F.READU(FN.REDO.FC.CL.BALANCE,CREATE.ARRANGEMENT.ID,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,ERR.MSJ,ERR.Y)
    IF R.REDO.FC.CL.BALANCE THEN



        R.REDO.FC.CL.BALANCE<FC.CL.AA.AMOUNT> = CREATE.ARRANGEMENT.AMOUNT
        R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE> = CREATE.ARRANGEMENT.BALANCE
        R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.RIGHT> = CREATE.ARRANGEMENT.COLL.RIGHT
        R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID> = CREATE.ARRANGEMENT.COLL
        R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL> = MG.ACTUAL
        R.REDO.FC.CL.BALANCE<FC.CL.MG.ORIGINAL> = MG.ACTUAL

        CALL F.WRITE(FN.REDO.FC.CL.BALANCE,CREATE.ARRANGEMENT.ID,R.REDO.FC.CL.BALANCE)



    END



    GOSUB UPDATE.CONCAT

RETURN

*
* =========
UPDATE.CONCAT:
* =========
*


    FN.REDO.FC.LIMIT.AA = "F.REDO.FC.LIMIT.AA" ;* Nombre concat file
    CALL CONCAT.FILE.UPDATE(FN.REDO.FC.LIMIT.AA,CREATE.ARRANGEMENT.LIMIT,CREATE.ARRANGEMENT.ID,'I','AR')

RETURN


*
* =========
UPDATE.COLLATERAL:
* =========
*

    R.COLLATERAL<COLL.LOCAL.REF,Y.AVAIL.VAL.FIELD.NO> = SALDO.DIS

    Y.COUNT.C = DCOUNT(CREATE.ARRANGEMENT.COLL,@VM)
    FOR Y.C = 1 TO Y.COUNT.C
        CALL F.READU(FN.COLLATERAL,CREATE.ARRANGEMENT.COLL<1,Y.C>,R.COLLATERAL,F.COLLATERAL,ERR.MSJ,RTR)
        IF R.COLLATERAL THEN
            IF SALDO.DIS<1,Y.C> EQ "" THEN
                SALDO.DIS<1,Y.C> = CREATE.ARRANGEMENT.SD<1,Y.C>
            END
            R.COLLATERAL<COLL.LOCAL.REF,Y.AVAIL.VAL.FIELD.NO>=SALDO.DIS<1,Y.C>

* R.COLLATERAL<COLL.LOCAL.REF,WPOSLI>=SALDO.DIS<1,Y.C>
            CALL F.WRITE(FN.COLLATERAL,CREATE.ARRANGEMENT.COLL<1,Y.C>,R.COLLATERAL)
        END
    NEXT Y.C

RETURN
*
*
* =========
OPEN.FILES:
* =========
*


    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
RETURN
*
* =========
INITIALISE:
* =========
*

    CREATE.ARRANGEMENT.ID = MAINT.ID.AA
    CREATE.ARRANGEMENT.AMOUNT = MAINT.AMOUNT
    CREATE.ARRANGEMENT.BALANCE = MAINT.AMOUNT.BALANCE
    CREATE.ARRANGEMENT.COLL = MAINT.COLL.ID.EXTRA
    CREATE.ARRANGEMENT.COLL.RIGHT = MAINT.COLL.ID.EXTRA.CHECK
    CREATE.ARRANGEMENT.SD = MAINT.COLL.MG.ORIGINAL.TOTAL
    CREATE.ARRANGEMENT.LIMIT = MAINT.LIMIT

    LOOP.CNT = 1
    MAX.LOOPS = 1
    PROCESS.GOAHEAD = 1

    R.REDO.FC.CL.BALANCE=""
    FN.REDO.FC.CL.BALANCE="F.REDO.FC.CL.BALANCE"
    F.REDO.FC.CL.BALANCE=""

    R.COLLATERAL=""
    FN.COLLATERAL="F.COLLATERAL"
    F.COLLATERAL=""

    Y.AVAIL.VAL.FIELD.NO = ''
    CALL GET.LOC.REF('COLLATERAL','L.COL.VAL.AVA',Y.AVAIL.VAL.FIELD.NO)

* WCAMPO ="L.CO.FILE.DATE"
* WCAMPO<2> = "L.COL.AVAIL.BAL"
* WCAMPO = CHANGE(WCAMPO,FM,VM)
* CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,ZPOS)
* WPOSL=ZPOS<1,1>
* WPOSLI=ZPOS<1,2>





RETURN

* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*

*
RETURN
*

END
