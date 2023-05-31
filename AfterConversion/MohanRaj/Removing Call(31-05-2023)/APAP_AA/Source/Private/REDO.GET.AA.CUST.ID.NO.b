$PACKAGE APAP.AA
SUBROUTINE REDO.GET.AA.CUST.ID.NO
*---------------------------------------------------
*MODIFICATION HISTORY:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL       AUTO R22 CODE CONVERSION           VM TO @VM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA

    
*----------------------------------------------
* Description: This routine is to return the document identity no. of that customer
*----------------------------------------------
* Input  Arg: N/A
* Output Arg: N/A
* Deals with: AA Overview Screen
*----------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_ENQUIRY.COMMON
    GOSUB PROCESS
RETURN
*----------------------------------------------
PROCESS:
*----------------------------------------------
    IF O.DATA THEN
        Y.CUS.ID = O.DATA
    END ELSE
        O.DATA = ''
        RETURN
    END
    GOSUB INIT

    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUST,F.CUSTOMER,CUS.ERR)
    IF R.CUST THEN
        Y.CUS.TYPE = R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.TIPO.CL>
        GOSUB GET.CUSTOMER.DETAILS
    END ELSE
        O.DATA = ''
        RETURN
    END

RETURN
*----------------------------------------------
GET.CUSTOMER.DETAILS:
*----------------------------------------------
    ID_CARD = ''
    BEGIN CASE
        CASE Y.CUS.TYPE EQ 'PERSONA FISICA'
            GOSUB FIS.TYPE
        CASE Y.CUS.TYPE EQ 'PERSONA JURIDICA'
            GOSUB JUR.TYPE
        CASE OTHERWISE
            GOSUB OTHER.TYPE
    END CASE
    O.DATA = ID_CARD
RETURN

*----------------------------------------------
FIS.TYPE:
*----------------------------------------------
    CIDENT.VALUE = R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.CIDENT>
    IF CIDENT.VALUE THEN
        ID_CARD = CIDENT.VALUE
    END ELSE
        ID_CARD = R.CUST<EB.CUS.LEGAL.ID,1>
    END

RETURN
*----------------------------------------------
JUR.TYPE:
*----------------------------------------------

    ID_CARD = R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.RNC>

RETURN
*----------------------------------------------
OTHER.TYPE:
*----------------------------------------------

    CIDENT.VALUE  =  R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.CIDENT>
    IF CIDENT.VALUE THEN
        ID_CARD = CIDENT.VALUE
        FLAG.ID = 1
    END
    IF NOT(FLAG.ID) THEN
        LEGALID.VALUE = R.CUST<EB.CUS.LEGAL.ID,1>
        IF LEGALID.VALUE THEN
            ID_CARD = LEGALID.VALUE
            FLAG.ID = 1
        END
    END
    IF NOT(FLAG.ID) THEN
        ACTANAC.VALUE = R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.ACTANAC>
        IF ACTANAC.VALUE THEN
            ID_CARD = ACTANAC.VALUE
            FLAG.ID = 1
        END
    END
    IF NOT(FLAG.ID) THEN
        NOUNICO.VALUE = R.CUST<EB.CUS.LOCAL.REF,POS.L.CU.NOUNICO>
        IF NOUNICO.VALUE THEN
            ID_CARD = NOUNICO.VALUE
            FLAG.ID = 1
        END
    END


RETURN
*----------------------------------------------
INIT:
*----------------------------------------------

    LREF.APPL = 'CUSTOMER'
    LREF.FIELDS = 'L.CU.CIDENT':@VM:'L.CU.TIPO.CL':@VM:'L.CU.RNC':@VM:'L.CU.ACTANAC':@VM:'L.CU.NOUNICO' ;*AUTO R22 CODE CONVERSION
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APPL,LREF.FIELDS,LREF.POS)
    POS.L.CU.CIDENT  = LREF.POS<1,1>
    POS.L.CU.TIPO.CL = LREF.POS<1,2>
    POS.L.CU.RNC     = LREF.POS<1,3>
    POS.L.CU.ACTANAC = LREF.POS<1,4>
    POS.L.CU.NOUNICO = LREF.POS<1,5>

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)


RETURN
END
