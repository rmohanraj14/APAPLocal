$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.S.FC.AA.ACTIVIDAD.GR(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.FC.ENQPARMS
* Attached as     : ROUTINE
* Primary Purpose : Get the value of industry description
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
* Date           Who                 Reference                                    Descripition
* 29-03-2023     Samaran T            Manual R22 Code Conversion               Package Name Added APAP.AA
* 29-03-2023    Conversion Tool        Auto R22 Code Conversion                 No Changes
*-----------------------------------------------------------------------------------
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Bryan Torres- TAM Latin America
* Date            : 9/26/2001
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER
*   $INCLUDE GLOBUS.BP I_F.INDUSTRY
    $INSERT I_F.APAP.INDUSTRY

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
*       Y.INDUSTRY = R.CUSTOMER<EB.CUS.INDUSTRY>
        Y.INDUSTRY = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.L.APAP.INDUS.POS>
    END

*   CALL F.READ(FN.INDUSTRY,Y.INDUSTRY,R.INDUSTRY,F.INDUSTRY,Y.ERR.INDUSTRY)
    CALL F.READ(FN.APAP.INDUSTRY,Y.INDUSTRY,R.INDUSTRY,F.APAP.INDUSTRY,Y.ERR.INDUSTRY)

    IF Y.ERR.INDUSTRY THEN
        AA.ARR = Y.ERR.INDUSTRY
        RETURN
    END ELSE
*       AA.ARR = R.INDUSTRY<EB.IND.DESCRIPTION>
        Y.USER.LANG = LNGG
        AA.ARR = R.INDUSTRY<REDO.DESCRIPTION,Y.USER.LANG>
        IF AA.ARR EQ '' THEN
            AA.ARR = R.INDUSTRY<REDO.DESCRIPTION,1>
        END
    END



RETURN
*------------------------
INITIALISE:
*=========

    Y.LOC.APPLICATION = 'CUSTOMER'
    Y.LOC.FIELD = 'L.APAP.INDUSTRY'
    Y.LOC.FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(Y.LOC.APPLICATION,Y.LOC.FIELD,Y.LOC.FIELD.POS)

    Y.L.APAP.INDUS.POS = Y.LOC.FIELD.POS<1,1>

    PROCESS.GOAHEAD = 1

    FN.CUSTOMER="F.CUSTOMER"
    F.CUSTOMER=""
    Y.CUS.ID = AA.ID


*   FN.INDUSTRY="F.INDUSTRY"
*   F.INDUSTRY=""
    FN.APAP.INDUSTRY = 'F.APAP.INDUSTRY'
    F.APAP.INDUSTRY = ''

RETURN
*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.APAP.INDUSTRY,F.APAP.INDUSTRY)
RETURN
*------------
END
