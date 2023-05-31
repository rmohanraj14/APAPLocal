$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.S.FC.AA.BL.AIGING(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose : REDO.S.FC.AA.BL.AIGING
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
* 29-03-2023    Conversion Tool    Auto R22 Code Conversion                   VM TO @VM, I TO I.VAR ,<I> TO <I.VAR>
*------------------------------------------------------------------------------------
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            :
*
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ACT.DET.ERR)
    Y.ACT.DET.ERR.HST = ''; R.AA.ACCOUNT.DETAILS.HST = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS.HST,Y.ARRG.ID,R.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST,Y.ACT.DET.ERR.HST)

    IF R.AA.ACCOUNT.DETAILS NE '' THEN
        Y.CONT = 1 ;NRO.BILLS.L = ''
        NRO.BILLS.L = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
        Y.CONT = DCOUNT(NRO.BILLS.L,@VM)

        FOR I.VAR=1 TO Y.CONT
            BILL.REFERENCE = NRO.BILLS.L<1,I.VAR>
            IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,I.VAR,1> EQ 'PAYMENT' THEN
                AA.ARR += 1
            END
        NEXT
    END
    IF R.AA.ACCOUNT.DETAILS.HST NE '' THEN
        Y.CONT = 1 ; NRO.BILLS.H = ''
        NRO.BILLS.H = R.AA.ACCOUNT.DETAILS.HST<AA.AD.BILL.ID>
        Y.CONT = DCOUNT(NRO.BILLS.H,@VM)

        FOR I.VAR=1 TO Y.CONT
            BILL.REFERENCE = NRO.BILLS.H<1,I.VAR>
            IF R.AA.ACCOUNT.DETAILS.HST<AA.AD.BILL.TYPE,I.VAR,1> EQ 'PAYMENT' THEN
                AA.ARR += 1
            END
        NEXT
    END

RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    B.CONT = 0
    Y.ARRG.ID = AA.ID
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS  = ''
    R.AA.ACCOUNT.DETAILS = ''
    AA.ARR = 0
    Y.BL.STATUS = 'AGING'
    Y.DAT.YAGO = TODAY
    CALL CDT("", Y.DAT.YAGO,'-365C')
    FN.AA.ACCOUNT.DETAILS.HST = 'F.AA.ACCOUNT.DETAILS.HIST'; F.AA.ACCOUNT.DETAILS.HST = ''
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.AA.ACCOUNT.DETAILS.HST,F.AA.ACCOUNT.DETAILS.HST)
RETURN
*------------
END
