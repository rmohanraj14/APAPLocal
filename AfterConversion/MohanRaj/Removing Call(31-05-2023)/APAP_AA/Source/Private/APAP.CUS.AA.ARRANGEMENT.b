$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE APAP.CUS.AA.ARRANGEMENT(CUST.LIST,AA.LIST)
*
*
*=====================================================================
* Subroutine Type : NOFILE ROUTINE
* Attached to     :
* Attached as     :
* Primary Purpose :
*---------------------------------------------------------------------
*Modification History:
*
* Date                     Who                        Reference                                        Description
* ----                    ----                                ----                                        ----
* 29-March-2023          Ajith Kumar              Manual R22 Code Conversion                Package Name added APAP.AA
* 29-March-2023     Conversion Tool                              R22 Auto Code Conversion                              No Change
*


*
* Development for : APAP
* Development by  : cherrera
* Date            : 2011-08-01
*=====================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT

************************************************************************


    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

************************************************************************

INIT:
    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER=''

    FN.AA.ARRANGEMENT='F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT=''

RETURN

************************************************************************

OPENFILES:
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

RETURN

************************************************************************

PROCESS:

*READ CUSTOMER LIST AND FIND ALL ARRANGEMENT FOR EACH CUSTOMER
    SEL.CMD="SELECT ":FN.CUSTOMER:" WITH @ID EQ ":CUST.LIST
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,RET.CODE)

    LOOP
        REMOVE CUS.ID FROM SEL.LIST SETTING CUS.POS
    WHILE CUS.ID:CUS.POS
*READ ARRANGEMENT LIST
        SEL.CMD2="SELECT ":FN.AA.ARRANGEMENT:" WITH CUSTOMER EQ ":CUS.ID
        CALL EB.READLIST(SEL.CMD2,SEL.LIST2,'',NO.OF.REC2,RET.CODE2)
        LOOP

            REMOVE AA.ID FROM SEL.LIST2 SETTING AA.POS
        WHILE AA.ID:AA.POS
*RETURN THE LIST:<CUSTOMER>,<ARRANGEMENT>
            AA.LIST<-1>=CUS.ID:"*":AA.ID
        REPEAT

    REPEAT

RETURN

************************************************************************

END
