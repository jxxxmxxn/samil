<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="../1.main/user_header.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>

    #content {
		margin-left: 650px;
		padding: 20px;
		margin-top: 50px;
	}
	
	@media print {
	 	@page {
            size: A4; /* 페이지 크기 설정 (A4) */
            margin: 0; /* 여백 제거 */
        }
        
	    body * {
	        display: none; /* 모든 요소 숨김 */
	        transform: scale(0.9);
	        height: auto;
	    }
	    #printableArea, #printableArea * {
	        display: block; /* 인쇄할 영역 보이기 */
	    }
	}
	
	.draft {
		width: 350px;
        border-collapse: collapse;
        margin-bottom: 10px;
        overflow: hidden;
	}
	
	table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 10px;
        overflow: hidden;
    }
    th {
   		width: 200px;
        padding: 5px;
        border: 1px solid #ddd;
        text-align: left;  
        color: black;          
        background-color: #FFF; 
        color: black;
        font-size: 16px;  
    }
    
    td {
    	width: 60%;
        padding: 5px;
        border: 1px solid #ddd;
        text-align: left;  
        color: black; 
    }
    select {
        width: 100px;
        height: 30px;
        text-align: center;
        appearance: none; /* 브라우저 기본 스타일 제거 */
    }
    .item-code {
	    background-color: #f2f2f2; /* 항목코드 배경색 */
	    text-align: center;          /* 정렬 */
	    padding: 10px;            /* 패딩 */
	}
	
	.content {
	    background-color: #e0f7fa; /* 내용 배경색 */
	    text-align: center;        /* 정렬 */
	    padding: 10px;            /* 패딩 */
	}
	
	.amount {
	    background-color: #ffe0b2; /* 금액 배경색 */
	    text-align: center;         /* 정렬 */
	    padding: 10px;            /* 패딩 */
	}
	
	button {
    	border: none;
    	color: red;
    }
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
	let selectedApprovers = [];
	let selectedReferrers = [];
	let modalType = 'approver'; // 기본값: 결재자
	
	// 모달 열기
	function openApproverModal() {
		
		$('#myForm').off('submit');
		
	    $.ajax({
	        url: '<%=request.getContextPath()%>/se/empDeptApp',
	        method: 'GET',
	        dataType: 'json',
	        success: function(data) {
	            populateEmpList(data);
	        },
	        error: function(jqXHR, textStatus, errorThrown) {
	            console.error('직원 데이터 가져오기 오류:', textStatus, errorThrown);
	        }
	    });
	}
	
	// 모달 닫기 함수
	function closeModal() {
	    // 모달 닫기
	    $('#addressModal').modal('hide');
		
	    // 유효성 검사 다시 활성화
	    $('#myForm').on('submit', function(event) {
	        // 유효성 검사 로직
	        if (!validateForm()) {
	            event.preventDefault(); // 폼 제출 방지
	        }
	    });
	}

	// 입력 필드 유효성 검사 함수
	function validateForm() {
	    // 예: 필수 입력 필드 검사
	    const isValid = $('#usagePeriod').val() && $('#furloughStartDate').val() && $('#furloughEndDate').val();
	    if (!isValid) {
	        alert('모든 필드를 입력해주세요.');
	    }
	    return isValid;
	}
	
	// 직원 목록 채우기
	function populateEmpList(empList) {
	    const empListContainer = $('.accordion');
	    empListContainer.empty(); // 이전 결과 초기화
	
	    if (empList.length === 0) {
	        empListContainer.append('<div>직원이 없습니다.</div>');
	        return;
	    }
	
	    const deptList = empList.reduce((acc, employee) => {
	        const deptName = employee.deptName;
	        if (deptName) {
	            if (!acc[deptName]) {
	                acc[deptName] = [];
	            }
	            acc[deptName].push(employee);
	        } else {
	            console.error('부서명이 없습니다:', employee);
	        }
	        return acc;
	    }, {});
	
	    Object.keys(deptList).forEach(deptName => {
	        let departmentItem = `
	            <div class="accordion-item">
	                <h2 class="accordion-header">
	                    <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapse` + deptName + `" aria-expanded="false" aria-controls="collapse` + deptName + `">
	                        ` + deptName + `
	                    </button>
	                </h2>
	                <div id="collapse` + deptName + `" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
	                    <div class="accordion-body>
	        `;
	
	        const sortedEmployees = deptList[deptName].sort((a, b) => b.grade - a.grade);
	        
	        sortedEmployees.forEach(employee => {
	            let gradeLabel = getGradeLabel(employee.grade);
	            let jobLabel = getJobLabel(employee.job);
	            if (gradeLabel || jobLabel) {
	                departmentItem += `
	                	<div style="cursor: pointer;">
	                    <button type="button" class="btn btn-link" onclick="addToList('` + employee.name + `', '` + employee.empno + `', '` + gradeLabel + `', '` + jobLabel + `')" style="text-decoration: none;">
	                        <strong>` + employee.empno + `</strong> ` + employee.name + ` ` + gradeLabel + ` ` + jobLabel + `
	                    </button>
	                </div>
	                `;
	            }
	        });
	
	        departmentItem += `
	                    </div>
	                </div>
	            </div>
	        `;
	
	        empListContainer.append(departmentItem);
	    });
	}
	
	// 직급과 직무 라벨 변환
	function getGradeLabel(grade) {
	    switch (grade) {
	        case 100: return '사원';
	        case 110: return '주임';
	        case 120: return '대리';
	        case 130: return '과장';
	        case 140: return '차장';
	        case 150: return '부장';
	        case 160: return '사장';
	        default: return '';
	    }
	}
	
	function getJobLabel(job) {
	    switch (job) {
	        case 110: return '팀장';
	        case 120: return '대표';
	        default: return '';
	    }
	}
	
	let approverIdCounter = 110; // 결재자 ID 시작값
	let referrerIdCounter = 900;  // 참조자 ID 시작값
	
	// 직원 추가 함수
	function addToList(name, empno, gradeLabel, jobLabel) {
	    const newEntry = { name, empno, grade: gradeLabel, job: jobLabel };
	
	    if (modalType === 'approver') {
	        if (!selectedApprovers.some(item => item.empno === newEntry.empno)) {
	            if (selectedApprovers.length < 3) {
	                selectedApprovers.push(newEntry);
	                updateSelectedList('#selectedApprovers', selectedApprovers);
	                updateHiddenApproversInput();
	            } else {
	                console.warn('결재자는 최대 3명까지 선택할 수 있습니다.');
	            }
	        } else {
	            console.warn(name + '는 이미 선택되었습니다.');
	        }
	
	    } else {
	        if (!selectedReferrers.some(item => item.empno === empno) && !selectedApprovers.some(item => item.empno === empno)) {
	            selectedReferrers.push(newEntry);
	            updateSelectedList('#selectedReferrers', selectedReferrers);
	            updateHiddenReferrersInput();
	        } else {
	            console.warn(name + '는 이미 선택되었습니다.');
	        }
	    }
	}
	
	function updateSelectedApproval() {
	    const approverNames = selectedApprovers.map(approver => 
	        approver.name + ' ' + approver.grade
	    ).join(' ');
	    $('#selectedApproval').text(approverNames); // 결재자 이름 업데이트
	    $('#approvalList').text(approverNames);
	}
	
	// 선택 목록 업데이트
	function updateSelectedList(selector, list) {
	    const container = $(selector);
	    container.empty();
	
	    const title = selector === '#selectedApprovers' ? '결재자 목록' : '참조자 목록';
	    container.append('<h5>' + title + '</h5>');
	    
	    list.forEach(item => {
	        container.append(`
	            <div>
	                ` + item.empno + ` ` + item.name + ` ` + item.grade + ` ` + item.job + `
	                <button onclick="removeFromList('` + item.empno + `', '` + selector + `')">X</button>
	            </div>
	        `);
	    });
	}
	
	// 목록에서 제거
	function removeFromList(empno, type) {
	    if (type === 'approver') {
	        selectedApprovers = selectedApprovers.filter(item => item.empno !== empno);
	        updateSelectedList('#selectedApprovers', selectedApprovers);
	        updateHiddenApproversInput();
	    } else {
	        selectedReferrers = selectedReferrers.filter(item => item.empno !== empno);
	        updateSelectedList('#selectedReferrers', selectedReferrers);
	        updateHiddenReferrersInput();
	    }
	}
	
	// 결재자 목록 업데이트 함수
	function updateHiddenApproversInput() {
		const approversData = selectedApprovers.map(approver => approver.empno);
	    $('#selectedApproversInput').val(approversData.join(',')); // 배열을 문자열로 변환하여 설정
	}

	// 참조자 목록 업데이트 함수
	function updateHiddenReferrersInput() {
	    const referrersData = selectedReferrers.map(referrer => referrer.empno);
	    $('#selectedReferrersInput').val(referrersData.join(',')); // 배열을 문자열로 변환하여 설정
	}
	
	// 모달 유형 설정
	function setModalType(type) {
	    modalType = type;
	    openApproverModal(); // 모달 열기
	    
	 // 모달 이벤트 리스너 등록
	    $('#addressModal').off('hidden.bs.modal').on('hidden.bs.modal', function () {
	        console.log('모달이 완전히 닫혔습니다.');
	        // 스크롤 활성화 코드
	        $('body').removeClass('modal-open'); // modal-open 클래스 제거
	        $('body').css('overflow', 'auto'); // 스크롤 활성화
	        $('.modal-backdrop').remove(); // 배경 제거
	        console.log('모달 배경이 제거되었습니다.');
	    });
	}
	
	function addApprovers() {
	    const approverNames = selectedApprovers.map(approver => 
	        approver.name + ' ' + approver.grade
	    ).join(' ');
	    $('#selectedApproval').text(approverNames); // 결재자 업데이트
	    $('#approvalList').text(approverNames);
	}
	
	function addReferrers() {
	    const referrerNames = selectedReferrers.map(referrer => 
	        referrer.name + ' ' + referrer.grade
	    ).join(', ');
	    $('#selectedReference').text(referrerNames); // 참조자 업데이트
	}
	
	// 모달 닫기 함수
	function closeModal() {
	    $('#addressModal').modal('hide');
	}
	
	// 추가 버튼 클릭 시
	function addSelectedMembers() {
	    addApprovers();
	    addReferrers();
	
	    // approversData와 referrersData를 생성
	    const approversData = selectedApprovers.map((approver, index) => ({
	        approverOrder: 110 + index * 10,
	        empno: approver.empno
	    }));
	
	    const referrersData = selectedReferrers.map((referrer, index) => ({
	        approverOrder: 900 + index,
	        empno: referrer.empno
	    }));
	
	 	// 기존에 선언된 변수가 있다면 재사용
	    const updatedApproversData = selectedApprovers.map((approver) => ({
	        empno: approver.empno
	    }));
	
	    $('#addressModal').modal('hide'); 
	    console.log('모달이 닫혔습니다.');
	}
	
	// 모달이 완전히 닫힐 때 호출되는 이벤트 리스너
	$('#addressModal').on('hidden.bs.modal', function () {
	    console.log('모달이 완전히 닫혔습니다.');
	    // 스크롤 활성화 코드
	    $('body').removeClass('modal-open'); // modal-open 클래스 제거
	    $('body').css('overflow', 'auto'); // 스크롤 활성화
	    $('.modal-backdrop').remove(); // 배경 제거
	    console.log('모달 배경이 제거되었습니다.');
	});
	
	// 이 부분을 추가하여 모달을 열기 전에 항상 이벤트 리스너를 등록
	$('#addressModal').on('show.bs.modal', function () {
	    // 모달이 열리면 스크롤 비활성화
	    $('body').addClass('modal-open');
	    $('body').css('overflow', 'hidden');
	    console.log('모달이 열렸습니다. 스크롤 비활성화.');
	});
	
	let currentRow = 1; // 현재 보이는 행의 인덱스
	
	function addRow() {
	    const maxRows = 5; // 최대 보이는 행 수
	    if (currentRow < maxRows) {
	        const nextRow = document.getElementById(`row${currentRow + 1}`);
	        nextRow.style.display = ''; // 행을 보이도록 설정
	        currentRow++; // 현재 행 인덱스 증가
	    }
	}
	
	function calculateTotal() {
	    let total = 0;
	    const rows = document.querySelectorAll('tr');

	    rows.forEach((row, index) => {
	        // 각 행의 금액 입력 필드 찾기
	        const amountInput = row.querySelector('input[name="costAmount"]');
	        if (amountInput) {
	            const amount = parseFloat(amountInput.value) || 0; // 금액이 숫자가 아닐 경우 0으로 처리
	            total += amount; // 합계에 추가
	        }
	    });

	    // 합계 필드에 결과 표시
	    document.getElementById('costTotal').value = total;
	}
	
	
	function addFileNames(divId, files) {
	    const fileNamesDiv = document.getElementById(divId);
	    fileNamesDiv.innerHTML = ""; // 기존 파일 이름 지우기
	
	    for (const file of files) {
	        const fileNameElement = document.createElement('div');
	        fileNameElement.textContent = file.name;
	        fileNamesDiv.appendChild(fileNameElement);
	    }
	}
    
    function goBack() {
        window.history.go(-2);
    }
    
    function resetForm() {
	    document.getElementById("myForm").reset();

	    // 파일 이름 초기화
	    document.getElementById('fileNames').innerHTML = "";
	    document.getElementById('attachedFileNames').innerHTML = "";

	    const tableBody = document.getElementById('tableBody');

	    // 테이블 본체가 존재할 경우 기존 행 모두 삭제
	    if (tableBody) {
	        while (tableBody.firstChild) {
	            tableBody.removeChild(tableBody.firstChild);
	        }
	    }

	    // 결재자 및 참조자 목록 초기화
	    selectedApprovers = [];
	    selectedReferrers = [];
	    updateSelectedList('#selectedApprovers', selectedApprovers);
	    updateSelectedList('#selectedReferrers', selectedReferrers);

	    // 결재자 및 참조자 텍스트 초기화
	    const selectedApprovalElement = document.getElementById('selectedApproval');
	    if (selectedApprovalElement) {
	        selectedApprovalElement.innerText = "";
	    }

	    const selectedReferenceElement = document.getElementById('selectedReference');
	    if (selectedReferenceElement) {
	        selectedReferenceElement.innerText = "";
	    }

	    // 모달에서 선택된 결재자 및 참조자 초기화
	    $('#addressModal').find('.selected-approvers, .selected-referrers').empty();
	}
</script>
<% 
	//documentFormId를 요청 파라미터에서 가져옴
	String documentFormId = request.getParameter("documentFormId");
	request.setAttribute("documentFormId", documentFormId);

	// formId를 documentFormId로 설정하고 변환
    String formId = documentFormId;
    
	if (formId != null) {
		switch (formId) {
			case "130": 
				formId = "법인"; 
				break;
		    case "140": 
		    	formId = "비품"; 
		    	break;
		    case "150": 
		    	formId = "유류비"; 
		    	break;
	    }
	}
%>
<title><%out.print(formId);%></title>
</head>
<body>
<main id="printableArea">
  	<div id="content" style="border: 1px solid #BDBDBD; width: 730px; margin-top: 30px; box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.5);">
    <form id="myForm" method="post" action="insertApp" enctype="multipart/form-data" style="padding: 20px">
    	<input type="hidden" name="documentFormId"  value="${documentFormId}">
        <input type="hidden" name="empno"           value="${emp.empno}">
        <input type="hidden" id="selectedApproversInput" name="selectedApprovers" value="">
		<input type="hidden" id="selectedReferrersInput" name="selectedReferrers" value="">
       
	  	<div style="border-bottom: 1px solid #BDBDBD;">
        	<h2><%out.print(formId);%> 승인 기안</h2>
        	<p>
		</div> 
		<p>	
		
	  	<div style="display: flex; border-bottom: 1px solid #BDBDBD;">
	  		<div>
		        <table class="draft">
		            <tr>    
		                <th style="width: 150px;">기안일자</th>
		                <td id="approvalDate"><%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %></td>
		            </tr>
		            <tr>    
		                <th style="width: 150px;">기안자</th>
		                <td>${emp.name}</td>
		            </tr>
		            <tr>    
		                <th style="width: 150px;">기안자부서</th>
		                <td>${emp.deptno}</td>
		            </tr>
		            <tr>    
		                <th style="width: 150px;">기안자직급</th>
		                <td>${gradeName} ${jobName}</td>
		            </tr>
		        </table>
	        </div>
        
	        <div style="margin-left: 50px;">
				<table style="border-collapse: collapse;">
			        <tr>
			        <td style="text-align: center; vertical-align: middle; padding-top: 10px; padding-left: 0px; padding-right: 0px; width: 20px; height: 170px; 
			                   writing-mode: vertical-rl; letter-spacing: 25px; border: 1px solid #BDBDBD;" rowspan="3">결재</td>
			            <c:forEach var="appLine" items="${appLineList}" varStatus="status">
			                <c:if test="${appLine.approverOrder <= 130}">
			                    <td style="text-align: center; vertical-align: middle; border: 1px solid #BDBDBD;">
			                        ${appLine.name}<br/>
			                        <c:choose>
			                            <c:when test="${appLine.grade == 100}">사원</c:when>
			                            <c:when test="${appLine.grade == 110}">주임</c:when>
			                            <c:when test="${appLine.grade == 120}">대리</c:when>
			                            <c:when test="${appLine.grade == 130}">과장</c:when>
			                            <c:when test="${appLine.grade == 140}">차장</c:when>
			                            <c:when test="${appLine.grade == 150}">부장</c:when>
			                            <c:when test="${appLine.grade == 160}">사장</c:when>
			                            <c:otherwise>( ${appLine.grade} )</c:otherwise>
			                        </c:choose>
			                    </td>
			                </c:if>
			            </c:forEach>
			        </tr>
			
			        <tr>
			            <c:forEach var="appLine" items="${appLineList}" varStatus="status">
			                <c:if test="${appLine.approverOrder <= 130}">
			                    <td style="text-align: center; vertical-align: middle; border: 1px solid #BDBDBD;">
			                        <c:choose>
			                            <c:when test="${appLine.approvalType == 120 || appLine.approvalType == 140}">
		                                <img src="/se/Yes.png" alt="Final Yes" style="width: 80px; height: 80px;"/> 
			                            </c:when>
			                            <c:when test="${appLine.approvalType == 130}">
		                                <img src="/se/None.png" alt="None" style="width: 80px; height: 80px;"/> 
			                            </c:when>
			                            <c:when test="${appLine.approvalType == 110}">
		                                <img src="/se/FinalYes.png" alt="Yes" style="width: 80px; height: 80px;"/> 
			                            </c:when>
			                            <c:when test="${appLine.approvalType == 100}">
		                                <img src="/se/Re.png" alt="Re" style="width: 80px; height: 80px;"/> 
			                            </c:when>
			                            <c:otherwise></c:otherwise>
			                        </c:choose>
			                    </td>
			                </c:if>
			            </c:forEach>
			        </tr>
			        <tr>
			            <c:forEach var="appLine" items="${appLineList}" varStatus="status">
			                <c:if test="${appLine.approverOrder <= 130}">
			                    <td style="text-align: center; vertical-align: middle; font-size: 14px; border: 1px solid #BDBDBD;">
			                        <c:if test="${appLine.approvalType != 100}">
			                            <fmt:formatDate value="${appLine.approvalCompleteDate}" pattern="yyyy-MM-dd" /><br />
			                        </c:if>
			                    </td>
			                </c:if>
			            </c:forEach>
			        </tr>
			    </table>
		    </div>
        </div>
        
        <div style="border-bottom: 1px solid #BDBDBD;">	
        <p>
        <table class="title">
            <tr>
            	<td style="text-align: center; width: 60px; font-weight: bold;">결재</td>
			    <td id="selectedApproval" style="text-align: center; width: 100px;"></td>
			    <td style="text-align: center; width: 80px;">
			        <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#addressModal" onclick="setModalType('approver')">결재</button>
			    </td>
			</tr>
			<tr>
				<td style="text-align: center; width: 60px; font-weight: bold;">참조</td>
			    <td id="selectedReference" style="text-align: center; width: 100px;"></td>
			    <td style="text-align: center; width: 80px;">
			        <button type="button" class="btn btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#addressModal" onclick="setModalType('referrer')">참조</button>
			    </td>
			</tr>
            <tr>
			    <td style="text-align: center; width: 60px; font-weight: bold;">제목</td>
			    <td>
			        <input type="text" id="approvalTitle" name="approvalTitle" style="text-align: center; width: 100%;" required>
			    </td>
			</tr>
        </table>
        </div>
        <p>
        <p>
        <h6 style="text-align: center; font-weight: bold;"> - 아래와 같이 기안하오니 검토 후 결재 바랍니다 - </h6>
        <br>
        
        <h3><%out.print(formId);%> 요청 정보</h3>
        <p>
		<table style="border: 1px solid #BDBDBD; padding: 10px; margin-bottom: 20px; margin-right: 25px;">
	        <tr>
	            <th class="item-code" style="width : 300px; text-align: center;">항목코드</th>
				<th class="content" style="width : 1300px; text-align: center;">내용</th>
				<th class="amount" style="width : 300px; text-align: center;">금액</th>
	        </tr>
	        
	        <tr>
			    <td>
			        <select id='costDetailsCode' name='costDetailsCode' style="text-align: center;"> <!-- 항목코드 -->
			            <option value="100">비품</option>
			            <option value="110">유류비</option>
			            <option value="120">공과금</option>
			            <option value="130">특수비용</option>
			        </select>
			    </td>
			    <td>
			        <input type="text" name="costDetailsCnt" style="text-align: center; width : 400px;" placeholder="내용 입력"> <!-- 내용 -->
			    </td>
			    <td>
			        <input type="number" name="costAmount" style="text-align: center; width : 100px;" placeholder="  금액 입력" oninput="calculateTotal();"> <!-- 금액 -->
			    </td>
			</tr>
		</table>
		<br>
		
        <div>
	        <p>
			<h4>첨부 파일</h4>
		   	<div style="margin-bottom: 20px;">
				<input type="file"  name="imageAttachment" class="file-upload" >
			</div>
		</div>

	    <div class="btn-group" style="text-align: center; margin-left: 210px;">
		    <button type="submit" class="btn btn-outline-primary">작성</button>
		    <button type="button" class="btn btn-outline-secondary" onclick="resetForm()">초기화</button>
		    <button type="button" class="btn btn-outline-danger" onclick="deleteForm()">삭제</button>
		    <button type="button" class="btn btn-outline-dark" onclick="goBack()">목록</button>
		</div>
    
 	<!-- 모달 -->
	<div class="modal fade" id="addressModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true" data-bs-backdrop="static">
	    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
	        <div class="modal-content">
	            <div class="modal-header">
	                <h1 class="modal-title fs-5" id="exampleModalLabel">결재라인 추가</h1>
	                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	            </div>
	            <div class="modal-body">
	                <div class="container-fluid">
	                    <div class="row">
	                        <div class="col-sm-7">
	                            <div class="accordion accordion-flush" id="accordionFlushExample">
	                                <!-- 직원 아코디언 항목이 동적으로 추가될 부분 -->
	                            </div>
	                        </div>
	
	                        <div class="col-md-4 ms-auto">
	                            <div class="text-center">
	                                <span class="font-weight-bold text-primary"></span>
	                                <div class="selected-approvers text-start" id="selectedApprovers">
	                                    <!-- 선택된 결재자 목록 -->
	                                </div>
	                            </div>
	                            <hr>
	                            <div class="text-center">
	                                <span class="font-weight-bold text-primary"></span>
	                                <div class="selected-referrers text-start" id="selectedReferrers">
	                                    <!-- 선택된 참조자 목록 -->
	                                </div>
	                            </div>
	                        </div>
	                    </div>
	                </div>
	            </div>
	
	            <div class="modal-footer">
					<button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
					<button type="button" class="btn btn-outline-warning btn-sm" onclick="addSelectedMembers();">적용</button>
	            </div>
	        </div>
	    </div>
	</div>
	</form>
  </div>	
  <footer style="padding-bottom: 40px;"></footer>
</main>
</body>
</html>
