WITH Attend as (
	SELECT 
		Year(start_date) AS Year
		,start_date AS MrkStr_StartDate	
		,stud_id
		,base_id
		,round(sum(authorised_count) / sum(possible_count),4) as PercentageAuth
		,round(sum(Unauthorised_count) / sum(possible_count),4) as PercentageUnAuth
		,round(sum(Present_count) / sum(possible_count),4) as PercentageAtt
		,sum(present_count) as Present_sess
		,sum(possible_count) as Possible_Sess
		,sum(authorised_count) as Authorised_sess
		,sum(Unauthorised_count) as Unauthorised_sess
		,sum(Miss_count) as Miss_sess
				
	FROM 	
		( 
		SELECT
			Year(start_date)
		 	,stud_id
			,base_id
			,start_date
			,markstr
			,length(markstr)
			,Nvl(length(translate(markstr,'B*XYZ[#','B')),0) as Possible_Count
			,length(markstr) - Nvl(length(translate(markstr,'#BDJPVWL/\','#')),0) as Present_Count
			,length(markstr) - Nvl(length(translate(markstr,'#CEFHIMRST;','#')),0) as Authorised_Count
			,length(markstr) - Nvl(length(translate(markstr,'#GNOU','#')),0) as Unauthorised_Count
			,length(markstr) - Nvl(length(translate(markstr,'#-','#')),0) as Miss_Count
		FROM
			(

			 SELECT 
				stud_id, 
				base_id, 
				Start_date,
				Marks as Markstr
			FROM 
				DX_XML_Attendance 	 
			)
		)

	WHERE Possible_Count > 0
	Group by Year(start_date), start_date, stud_id, base_id
)

SELECT
	A.MrkStr_StartDate,
	A.Year,
	(A.Year || '/' || (TO_NUMBER((SUBSTR(A.Year,3,2)),'99')+1)) As AcYear,
	A.PercentageAuth, A.PercentageUnAuth, A.PercentageAtt, A.Present_sess, A.Possible_sess, A.Miss_sess, A.Authorised_Sess, A.Unauthorised_sess, 
	S.Stud_id, S.UP_ID, S.Forename, S.Surname, S.Gender, S.DoB, S.NCY AS Current_NCY,
	CASE floor(months_between(A.MrkStr_StartDate, S.DoB)/12) 
		WHEN 2 THEN -2 
		WHEN 3 THEN -1
		WHEN 4 THEN 0
		WHEN 5 THEN 1
		WHEN 6 THEN 2
		WHEN 7 THEN 3
		WHEN 8 THEN 4
		WHEN 9 THEN 5
		WHEN 10 THEN 6
		WHEN 11 THEN 7
		WHEN 12 THEN 8
		WHEN 13 THEN 9
		WHEN 14 THEN 10
		WHEN 15 THEN 11
		WHEN 16 THEN 12
		WHEN 17 THEN 13
		WHEN 18 THEN 14
		ELSE 99
	END AS NCY_Adjusted,

	B.Base_id, B.Base_Name, B.Type_id, B.Des_No, B.Cluster_Code

FROM 	
	Attend A,
	Student S,
	Bases B,
	Stud_Hist SH
	 
WHERE
	A.Stud_Id = SH.Stud_Id (+)
AND	A.Base_Id = SH.Base_id (+)
AND	SH.Stud_Id = S.Stud_Id (+)
AND	SH.Base_Id = B.Base_Id (+)
AND	B.Type_Id IN ('N','P','S','SP','MS')
AND	B.Lea_No = '673'
AND	A.Year >= '2011' 
AND	A.YEAR <= (SELECT (CASE WHEN MONTH(SYSDATE) > 8 THEN TO_CHAR(YEAR(SYSDATE) -1) ELSE TO_CHAR(YEAR(SYSDATE) -2) END ) AS STOPHERE FROM DUAL)
AND	floor(months_between(A.MrkStr_StartDate, S.DoB)/12) < 19

ORDER BY
	A.Year Desc