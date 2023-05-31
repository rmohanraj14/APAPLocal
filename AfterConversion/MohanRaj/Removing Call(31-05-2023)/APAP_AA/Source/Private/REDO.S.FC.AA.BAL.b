$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.S.FC.AA.BAL(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose : To return value of EB.CONTRACT.BALANCE>CURRCOMMITMENT field
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
*-----------------------------------------------------------------------------------
* Modification History:
* Date           Who                     Reference                                  Descripition
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA
* 29-03-2023   Conversion Tool    Auto R22 Code Conversion                   No Changes
*----------------------------------------------------------------------------------
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            :
*
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    BALANCE.TYPE='CURACCOUNT'
*BALANCE.TYPE='CURCOMMITMENT'
    SUB.TYPE = ''
    ECB.BALANCE = 0
    CALL AC.GET.ECB.BALANCE(ACCT.ID, BALANCE.TYPE, SUB.TYPE, TODAY,ECB.BALANCE,'')

    IF ECB.BALANCE THEN
        AA.ARR = ECB.BALANCE
    END ELSE
        AA.ARR = 'NULO'
    END
RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    LOCATE 'ACCOUNT' IN AA.ARR<AA.ARR.LINKED.APPL,1> SETTING POS THEN
        ACCT.ID = AA.ARR<AA.ARR.LINKED.APPL.ID,POS>
    END ELSE
        PROCESS.GOAHEAD = 0
        AA.ARR = "NULO"
    END
RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------
END
