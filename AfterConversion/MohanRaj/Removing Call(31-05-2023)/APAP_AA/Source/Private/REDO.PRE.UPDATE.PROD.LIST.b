$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.PRE.UPDATE.PROD.LIST
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine is attached as POST routine to update details in REDO.CUST.PRD.LIST
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
*
* 02-Jun-2011     Shankar Raju       PACS00063146       Initial Creation
*------------------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                        Descripition
* 29-03-2023     Samaran T            Manual R22 Code Conversion               Package Name Added APAP.AA
* 29-03-2023    Conversion Tool         Auto R22 Code Conversion                VM TO @VM
*----------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.REDO.CUST.PRD.LIST
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_AA.LOCAL.COMMON

    IF V$FUNCTION EQ 'A' THEN
        GOSUB INIT
        GOSUB PROCESS
        GOSUB UPD.PRD.LIST
        GOSUB UPD.JOINT.CUS.PRD.LIST
    END

RETURN
*------------------------------------------------------------------------------------------
INIT:
*----

    Y.ACCOUNT.ID = c_aalocLinkedAccount

    FN.CUST.PRD.LIST='F.REDO.CUST.PRD.LIST'
    F.CUST.PRD.LIST=''
    R.CUST.PRD.LIST = ''
    CALL OPF(FN.CUST.PRD.LIST,F.CUST.PRD.LIST)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    R.CUST.PRD.LIST = ''

RETURN

*------------------------------------------------------------------------------------------
PROCESS:
*-------

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACC)
    Y.CUSTOMER.ID = R.ACCOUNT<AC.CUSTOMER>


    CALL F.READ(FN.CUST.PRD.LIST,Y.CUSTOMER.ID,R.CUST.PRD.LIST,F.CUST.PRD.LIST,CUS.ERR)
    Y.PRD.LIST=R.CUST.PRD.LIST<PRD.PRODUCT.ID>

    LOCATE Y.ACCOUNT.ID IN Y.PRD.LIST<1,1> SETTING POSN.PRD THEN
        PRD.POS = POSN.PRD
    END ELSE
        PRD.POS = DCOUNT(Y.PRD.LIST,@VM) + 1
    END

RETURN

*------------------------------------------------------------------------------------------
UPD.PRD.LIST:
*------------
    R.CUST.PRD.LIST<PRD.PRODUCT.ID,PRD.POS> = Y.ACCOUNT.ID
    R.CUST.PRD.LIST<PRD.TYPE.OF.CUST,PRD.POS> = 'LOAN'
    R.CUST.PRD.LIST<PRD.PRD.STATUS,PRD.POS> ='ACTIVE'
    R.CUST.PRD.LIST<PRD.DATE,PRD.POS> = TODAY
    R.CUST.PRD.LIST<PRD.PROCESS.DATE> = TODAY
    CALL F.WRITE(FN.CUST.PRD.LIST,Y.CUSTOMER.ID,R.CUST.PRD.LIST)

RETURN
*------------------------------------------------------------------------------------------
UPD.JOINT.CUS.PRD.LIST:
*------------------------------------------------------------------------------------------
    Y.OTHER.PARTY.LIST = R.NEW(AA.CUS.OTHER.PARTY)
    Y.CUS.ROLE.LIST    = R.NEW(AA.CUS.ROLE)
    Y.TOT.OTHER.PARTY  = DCOUNT(Y.OTHER.PARTY.LIST,@VM)
    Y.JNT.CUS = 1
    LOOP
    WHILE Y.JNT.CUS LE Y.TOT.OTHER.PARTY
        IF Y.OTHER.PARTY.LIST<1,Y.JNT.CUS> AND Y.CUS.ROLE.LIST<1,Y.JNT.CUS> EQ 'CO-SIGNER' THEN
            Y.OTHER.PARTY.ID = Y.OTHER.PARTY.LIST<1,Y.JNT.CUS>
            GOSUB UPD.JOINT.CUS.WRITE
        END
        Y.JNT.CUS += 1
    REPEAT


RETURN
*------------------------------------------------------------------------------------------
UPD.JOINT.CUS.WRITE:
*------------------------------------------------------------------------------------------
    R.CUST.PRD.LIST = ''
    CUS.ERR = ''
    CALL F.READ(FN.CUST.PRD.LIST,Y.OTHER.PARTY.ID,R.CUST.PRD.LIST,F.CUST.PRD.LIST,CUS.ERR)
    Y.PRD.JNT.LIST=R.CUST.PRD.LIST<PRD.PRODUCT.ID>

    LOCATE Y.ACCOUNT.ID IN Y.PRD.JNT.LIST<1,1> SETTING POSN.JNT.PRD THEN
        PRD.JNT.POS = POSN.JNT.PRD
    END ELSE
        PRD.JNT.POS = DCOUNT(Y.PRD.JNT.LIST,@VM) + 1
    END

    R.CUST.PRD.LIST<PRD.PRODUCT.ID,PRD.JNT.POS> = Y.ACCOUNT.ID
    R.CUST.PRD.LIST<PRD.TYPE.OF.CUST,PRD.JNT.POS> = 'LOAN'
    R.CUST.PRD.LIST<PRD.PRD.STATUS,PRD.JNT.POS> ='ACTIVE'
    R.CUST.PRD.LIST<PRD.DATE,PRD.JNT.POS> = TODAY
    R.CUST.PRD.LIST<PRD.PROCESS.DATE> = TODAY
    CALL F.WRITE(FN.CUST.PRD.LIST,Y.OTHER.PARTY.ID,R.CUST.PRD.LIST)
RETURN
*------------------------------------------------------------------------------------------
END
*------------------------------------------------------------------------------------------
