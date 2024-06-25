WITH Attend as (
	SELECT 	
		stud_id
		,round(sum(authorised_count) / sum(possible_count),4) as PercentageAuth
		,round(sum(Unauthorised_count) / sum(possible_count),4) as PercentageUnAuth
		,round(sum(Present_count) / sum(possible_count),4) as PercentageAtt
		,sum(present_count) as Present_sess
		,sum(possible_count) as Possible_Sess
		,sum(authorised_count) as Authorised_sess
		,sum(Unauthorised_count) as Unauthorised_sess
		,sum(Miss_count) as Miss_sess
		,TO_CHAR(base_id) AS base_Id
		,markstr
		,start_date		
	FROM 	
		( 
		SELECT 	stud_id
			,base_id
			,start_date
			,markstr
			,length(markstr)
			,Nvl(length(translate(markstr,'B*XYZ[#','B')),0) as Possible_Count
			,length(markstr) - Nvl(length(translate(markstr,'#BDJPVWL/\','#')),0) as Present_Count
			,length(markstr) - Nvl(length(translate(markstr,'#CEFHIMRST;','#')),0) as Authorised_Count
			,length(markstr) - Nvl(length(translate(markstr,'#GNOU','#')),0) as Unauthorised_Count
			,length(markstr) - Nvl(length(translate(markstr,'#-','#')),0) as Miss_Count
			,Length(markstr) - Length(Translate(markstr,'#/','#')) AS AM_Count  
			,Length(markstr) - Length(Translate(markstr,'#\','#')) AS PM_Count
			,Length(markstr) - Length(Translate(markstr,'#B','#')) AS B_Count
			,Length(markstr) - Length(Translate(markstr,'#C','#')) AS C_Count
			,Length(markstr) - Length(Translate(markstr,'#D','#')) AS D_Count
			,Length(markstr) - Length(Translate(markstr,'#E','#')) AS E_Count
			,Length(markstr) - Length(Translate(markstr,'#F','#')) AS F_Count
			,Length(markstr) - Length(Translate(markstr,'#G','#')) AS G_Count
			,Length(markstr) - Length(Translate(markstr,'#H','#')) AS H_Count
			,Length(markstr) - Length(Translate(markstr,'#I','#')) AS I_Count
			,Length(markstr) - Length(Translate(markstr,'#J','#')) AS J_Count
			,Length(markstr) - Length(Translate(markstr,'#L','#')) AS L_Count
			,Length(markstr) - Length(Translate(markstr,'#M','#')) AS M_Count
			,Length(markstr) - Length(Translate(markstr,'#N','#')) AS N_Count
			,Length(markstr) - Length(Translate(markstr,'#O','#')) AS O_Count
			,Length(markstr) - Length(Translate(markstr,'#P','#')) AS P_Count
			,Length(markstr) - Length(Translate(markstr,'#R','#')) AS R_Count
			,Length(markstr) - Length(Translate(markstr,'#S','#')) AS S_Count
			,Length(markstr) - Length(Translate(markstr,'#T','#')) AS T_Count
			,Length(markstr) - Length(Translate(markstr,'#U','#')) AS U_Count
			,Length(markstr) - Length(Translate(markstr,'#V','#')) AS V_Count
			,Length(markstr) - Length(Translate(markstr,'#W','#')) AS W_Count
			,Length(markstr) - Length(Translate(markstr,'#X','#')) AS X_Count
			,Length(markstr) - Length(Translate(markstr,'#Y','#')) AS Y_Count
			,Length(markstr) - Length(Translate(markstr,'#Z','#')) AS Z_Count
			,Length(markstr) - Length(Translate(markstr,'/#','/')) AS Hash_Count
			,Length(markstr) - Length(Translate(markstr,'#!','#')) AS Exclamation_Count
			,Length(markstr) - Length(Translate(markstr,'#-','#')) AS Dash_Count
			,Length(markstr) - Length(Translate(markstr,'#@','#')) AS Ampersand_Count
			,Length(markstr) - Length(Translate(markstr,'#*','#')) AS Star_Count
			,Length(markstr) - Length(Translate(markstr,'#[','#')) AS SqBracket_Count
			,Length(markstr) - Length(Translate(markstr,'#;','#')) AS SemiColon_Count
		FROM
			(
			 SELECT 
				stud_id, 
				base_id, 
				Start_date,
				
				SubStr(A.Marks, 

                		CASE WHEN (SELECT MAX(Start_Date) FROM DX_XML_Attendance) < A.start_date 
                		  THEN 1 
               			  ELSE ((SELECT MAX(Start_Date) FROM DX_XML_Attendance) - A.start_date )*2 
                		END,
            
                		CASE WHEN (SELECT MAX(Start_Date) FROM DX_XML_Attendance) < A.start_date 
                			THEN ((SELECT SYSDATE FROM DUAL) - A.start_date)*2+2
		              		ELSE ((SELECT SYSDATE FROM DUAL) - (SELECT MAX(Start_Date) FROM DX_XML_Attendance))*2+1 
                		END) AS Markstr
			
			FROM 
				DX_XML_Attendance A
			
			WHERE 
				Year(start_date) >= CASE WHEN (SELECT MONTH(MAX(Start_Date)) FROM DX_XML_Attendance)  >8 
							 THEN (SELECT YEAR(MAX(Start_Date)) FROM DX_XML_Attendance) 
							 ELSE (SELECT YEAR(MAX(Start_Date)) FROM DX_XML_Attendance)-1 END

			AND 	Year(start_date) <= CASE WHEN (SELECT MONTH(SYSDATE) FROM DUAL)<9 
							 THEN (SELECT YEAR(SYSDATE) FROM DUAL)-1 
							 ELSE (SELECT YEAR(SYSDATE) FROM DUAL) END		 
			)
		)

	WHERE Possible_Count > 0
	Group by stud_id, base_Id, markstr, start_date
)

SELECT
	A.markstr,
	A.Base_Id, B.DES_No, B.Base_Name, A.PercentageAuth, A.PercentageUnAuth, A.PercentageAtt, A.Present_sess, A.Possible_sess, A.Miss_sess, A.Authorised_Sess, A.Unauthorised_sess, 
	S.Stud_id, S.Forename, S.Surname, S.NCY, S.UP_ID,
	SH.Start_Date as SH_Start, SH.End_Date as SH_End
		
FROM 	
	Attend A,
	Student S,
	Bases B,
	Stud_Hist SH
	 
WHERE
	A.Stud_Id = S.Stud_Id (+)
AND	A.Base_Id = B.Base_Id (+)
AND	A.Stud_Id = SH.Stud_Id (+)
AND	A.Base_Id = SH.Base_Id (+)
AND	A.Start_Date >= ('01/sep/' || (SELECT (CASE WHEN MONTH(SYSDATE) > 8 THEN TO_CHAR(YEAR(SYSDATE)) ELSE TO_CHAR(YEAR(SYSDATE) -1) END ) FROM DUAL))