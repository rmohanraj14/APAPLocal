$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.V.VAL.RATE.TYPE
    
*-----------------------------------------------------------------------------------
* Modification History: 
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023         SURESH      MANUAL R22 CODE CONVERSION        Package Name added APAP.AA
* 29/03/2023         Conversion Tool      AUTO R22 CODE CONVERSION           VM TO @VM
*-----------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------------------
*Company Name: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Program Name: REDO.V.VAL..RATE.TYPE
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Description:This routine will populate the effective rate for Fixed and Interest(first value of multi value set). For Floating Interest it will take interest rate from basic interest table plus margin rate (first value of multi value set)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Modification History:
*-------------------------------------------------------------------------------------------

*DATE             WHO         REFERENCE             DESCRIPTION
*29-06-2010      PREETHI MD    ODR-2009-10-0326 N.3  INITIAL CREATION
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON

* PACS00514667 -S
    Y.AA.STATUS = ''
    Y.AA.STATUS = c_aalocActivityStatus
    IF Y.AA.STATUS MATCHES 'REVERSE':@VM:'REV-DEL':@VM:'DEL':@VM:'AUTH-REV' ELSE ;*AUTO R22 CODE CONVERSION

        GOSUB INIT
        GOSUB PROCESS1
        GOSUB PROCESS2
    END
* PACS00514667 -E
RETURN

*------------------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------------------
    LOC.REF.APPLICATION='AA.PRD.DES.INTEREST'
    LOC.REF.FIELDS='L.AA.REV.RT.TY':@VM:'L.AA.FIR.REV.DT':@VM:'L.AA.RT.RV.FREQ':@VM:'L.AA.NXT.REV.DT' ;*AUTO R22 CODE CONVERSION

    LOC.REF.POS=''

RETURN
*-------------------------------------------------------------------------------------------
PROCESS1:
*-------------------------------------------------------------------------------------------


    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    Y.TYPE.POS             = LOC.REF.POS<1,1>
    Y.FIRST.POS            = LOC.REF.POS<1,2>
    Y.RATE.REVIEW.FREQ.POS = LOC.REF.POS<1,3>
    POS.L.AA.NXT.REV.DT    = LOC.REF.POS<1,4>

    Y.REV.TY            = R.NEW(AA.INT.LOCAL.REF)<1,Y.TYPE.POS>
    Y.FIR.REV           = R.NEW(AA.INT.LOCAL.REF)<1,Y.FIRST.POS>
    Y.NEXT.REVIEW.DATE  = R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.NXT.REV.DT>

    IF Y.REV.TY EQ "PERIODICO" THEN
        IF Y.FIR.REV EQ "" THEN
            AF=AA.INT.LOCAL.REF
            AV=Y.FIRST.POS
            ETEXT="AA-FIRST.REVIEW"
            CALL STORE.END.ERROR
            RETURN
        END
        Y.NEXT.WORKING.DAY = R.DATES(EB.DAT.NEXT.WORKING.DAY)
*        IF Y.FIR.REV LT Y.NEXT.WORKING.DAY THEN
        IF Y.FIR.REV LE TODAY AND Y.NEXT.REVIEW.DATE EQ '' THEN
            AF     = AA.INT.LOCAL.REF
            AV     = Y.FIRST.POS
            ETEXT  = 'EB-REDO.FIRST.REV.DATE'
            CALL STORE.END.ERROR
            RETURN
        END



    END

RETURN
*--------------------------------------------------------------------------------------------
PROCESS2:
*--------------------------------------------------------------------------------------------
    Y.FREQ=R.NEW(AA.INT.LOCAL.REF)<1,Y.RATE.REVIEW.FREQ.POS>

    IF Y.REV.TY EQ "PERIODICO" THEN
        IF Y.FREQ EQ "" THEN
            AF=AA.INT.LOCAL.REF
            AV=Y.RATE.REVIEW.FREQ.POS
            ETEXT="EB-REDO.RATE.REV.FREQ"
            CALL STORE.END.ERROR
        END
    END

RETURN

END
