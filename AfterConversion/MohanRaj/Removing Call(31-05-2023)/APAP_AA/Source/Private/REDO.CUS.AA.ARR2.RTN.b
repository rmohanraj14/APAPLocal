* @ValidationCode : Mjo2NTU4MzIxMjc6Q3AxMjUyOjE2ODAxODQ2NzIxMjI6SVRTUzotMTotMToxNjU6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 165
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.CUS.AA.ARR2.RTN(ENQ.DATA)
*
*
*--------------------------------------------------------------------------
* This routine fetches the Collateral IDs for the arrangement Specified
*
*---------------------------------------------------------------------------------------------------------
*
* Modification History
*
*2011-10-27 ejijon@temenos.com
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSTION           VM TO @VM ,FM TO @FM and I to I.VAR
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSTION            PACKAGE ADDED
*
*---------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
    $INSERT I_B02.COMMON

*---------------------------------------------------------------------------------------------------------
MAIN.LOGIC:
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*---------------------------------------------------------------------------------------------------------
INITIALISE:
    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    R.AA.ARR = ''

    CALL OPF (FN.AA.ARR, F.AA.ARR)

RETURN
*---------------------------------------------------------------------------------------------------------
PROCESS:

*IF ISDIGIT(D.RANGE.AND.VALUE<1>) THEN
*   RESERVED(1) = D.RANGE.AND.VALUE<1>
*END
*
*LOCATE "CUS.ID" IN D.FIELDS<1> SETTING Y.POS.ID THEN
*   Y.CUS = D.RANGE.AND.VALUE<Y.POS.ID>
*END
*
*IF ISDIGIT(Y.CUS) THEN
*   *Y.AA = RESERVED(1)
*END ELSE
*   Y.CUS = RESERVED(1)
*END


    Y.TOT.CUS = DCOUNT(COMM.CUS,@VM)

    FOR I.VAR=1 TO Y.TOT.CUS;* R22 Auto Conversion - variable name changed
        Y.CUS = COMM.CUS<1,I.VAR>;* R22 Auto Conversion - variable name changed
        SEL.CMD = 'SELECT ' : FN.AA.ARR : ' WITH CUSTOMER EQ ': Y.CUS
        CALL EB.READLIST(SEL.CMD,Y.LIST,'',NO.OF.REG,RET.CODE)
        LOOP
            REMOVE Y.AA.ID FROM Y.LIST SETTING POS
        WHILE Y.AA.ID:POS
            CALL F.READ(FN.AA.ARR,Y.AA.ID,R.AA.ARR,F.AA.ARR,Y.ERR)
            ENQ.DATA<-1> = Y.AA.ID: '*' : R.AA.ARR<AA.ARR.LINKED.APPL.ID>: '*' :R.AA.ARR<AA.ARR.CUSTOMER>
        REPEAT

    NEXT I.VAR;* R22 Auto Conversion - variable name changed
*ENQ.DATA = Y.LIST


RETURN
*---------------------------------------------------------------------------------------------------------
END
