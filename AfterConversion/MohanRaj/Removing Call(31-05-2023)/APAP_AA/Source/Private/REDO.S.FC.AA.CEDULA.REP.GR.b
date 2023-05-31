$PACKAGE APAP.AA;*Manual R22 code conversion
SUBROUTINE REDO.S.FC.AA.CEDULA.REP.GR(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.FC.ENQPARMS
* Attached as     : ROUTINE
* Primary Purpose : Show L.CU.CIDENT of the registers that match Risk group and Relation code equal to 104
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
* AA.ARR - data returned to the routine
*
* Error Variables:
*-------------------------------------------------------------------------------------------------------
* Modification History:
* Date           Who                     Reference                                  Descripition
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA
* 29-03-2023   Conversion Tool     Auto R22 Code Conversion                  FM TO @FM, VM TO @VM
*-----------------------------------------------------------------------------------------------------------
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Bryan Torres- TAM Latin America
* Date            : 9/26/2001
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======




    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,Y.ERR.CUSTOMER)
    IF Y.ERR.CUSTOMER THEN
        AA.ARR = Y.ERR.CUSTOMER
        RETURN
    END ELSE
        Y.RISK = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSRISK>
    END

    SELECT.STATEMENT = 'SELECT ':FN.CUSTOMER :' WITH L.CU.GRP.RIESGO ':'EQ ':Y.RISK
    LOCK.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    Y.ID.AA.PRD = ''
    CALL EB.READLIST(SELECT.STATEMENT,LOCK.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
    LOOP
        REMOVE Y.ID.CUS FROM LOCK.LIST SETTING POS
    WHILE Y.ID.CUS:POS
        CALL CACHE.READ(FN.CUSTOMER, Y.ID.CUS, R.CUS, Y.ERR.CUS)

        IF Y.ERR.CUS THEN
            AA.ARR = Y.ERR.CUS
            RETURN
        END ELSE
            Y.RELATION.CODE = R.CUS<EB.CUS.RELATION.CODE>
            Y.ROLE.MORE.INFO = R.CUS<EB.CUS.ROLE.MORE.INFO>
            Y.GET.CU.CIDENT = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOLCUCIDENT>
            GOSUB ADD.ARR
        END



    REPEAT
RETURN
*-----------------------------------------------------------------------------------
ADD.ARR:
*======

    Y.COUNT.CODE=DCOUNT(Y.RELATION.CODE,@VM)
    FOR Y.CODE = 1 TO Y.COUNT.CODE

        IF Y.RELATION.CODE<1,Y.CODE> EQ "104" THEN
            AA.ARR<-1>=Y.GET.CU.CIDENT<1,Y.CODE>
        END
    NEXT Y.CODE

    AA.ARR = CHANGE(AA.ARR,@FM," ")

RETURN

*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.CUSTOMER="F.CUSTOMER"
    F.CUSTOMER=""
    Y.CUS.ID = AA.ID
    WCAMPOU = "L.CU.GRP.RIESGO"
    WCAMPOU<2> = "L.CU.TIPO.CL"
    WCAMPOU<3> = "L.CU.CIDENT"
    WCAMPOU = CHANGE(WCAMPOU,@FM,@VM)
    YPOSU=''
    CALL MULTI.GET.LOC.REF("CUSTOMER",WCAMPOU,YPOSU)
    WPOSRISK  = YPOSU<1,1>
    WPOLCUTIPO  = YPOSU<1,2>
    WPOLCUCIDENT  = YPOSU<1,3>
    AA.ARR=""
    Y.RISK=""


RETURN
*------------------------
OPEN.FILES:
*=========
    CALL OPF (FN.CUSTOMER,F.CUSTOMER)

RETURN
*------------
END
