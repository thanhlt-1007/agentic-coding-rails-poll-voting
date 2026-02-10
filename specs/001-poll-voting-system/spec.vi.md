# Đặc Tả Tính Năng: Hệ Thống Bỏ Phiếu Poll

**Nhánh Tính Năng**: `001-poll-voting-system`  
**Ngày Tạo**: 10 tháng 2, 2026  
**Trạng Thái**: Bản Nháp  
**Mô Tả Đầu Vào**: "Xây dựng hệ thống tạo Poll, mời người khác vote, chốt kết quả theo deadline. Chủ poll tạo câu hỏi, lựa chọn, đặt deadline; người dùng nhận link/mã tham gia, vote một lần; kết quả hiển thị thời gian thực (ẩn/hiện theo cấu hình)."

## Kịch Bản Người Dùng & Kiểm Thử *(bắt buộc)*

### User Story 1 - Người Tạo Poll Tạo và Công Bố Poll (Ưu Tiên: P1)

Người tạo poll muốn tạo một poll với câu hỏi, nhiều lựa chọn, và thời hạn, sau đó chia sẻ với người tham gia.

**Tại sao ưu tiên này**: Đây là nền tảng của toàn bộ hệ thống - nếu không có khả năng tạo và công bố poll, không có chức năng nào khác có thể hoạt động. Điều này mang lại giá trị tức thì như một tính năng độc lập.

**Kiểm Thử Độc Lập**: Có thể được kiểm tra đầy đủ bằng cách tạo poll với câu hỏi "Màu yêu thích của bạn là gì?", các lựa chọn ["Đỏ", "Xanh dương", "Xanh lá"], thời hạn "15/02/2026 5:00 chiều", nhận link chia sẻ, và xác minh poll có thể truy cập qua link đó. Mang lại giá trị: người tạo poll có thể thu thập phiếu bầu ngay lập tức.

**Kịch Bản Chấp Nhận**:

1. **Cho trước** người dùng đang ở trang tạo poll, **Khi** người dùng nhập câu hỏi "Ăn gì trưa nay?", thêm lựa chọn "Pizza", "Sushi", "Burger", đặt thời hạn là ngày mai 12:00 trưa, **Thì** hệ thống tạo poll và cung cấp link chia sẻ
2. **Cho trước** người dùng tạo poll với tối thiểu 2 lựa chọn, **Khi** người dùng lưu poll, **Thì** poll được lưu với mã định danh duy nhất và mã truy cập
3. **Cho trước** người tạo poll đặt thời hạn là ngày quá khứ, **Khi** người dùng cố lưu poll, **Thì** hệ thống hiển thị lỗi xác thực "Thời hạn phải ở tương lai"
4. **Cho trước** người tạo poll chỉ thêm 1 lựa chọn, **Khi** người dùng cố lưu poll, **Thì** hệ thống hiển thị lỗi xác thực "Poll phải có ít nhất 2 lựa chọn"
5. **Cho trước** poll được tạo thành công, **Khi** người tạo poll nhận link, **Thì** định dạng link là `[app-url]/polls/[unique-code]` (ví dụ: `/polls/ABC123`)

---

### User Story 2 - Người Tham Gia Bỏ Phiếu Poll (Ưu Tiên: P1)

Người tham gia nhận link hoặc mã poll, xem câu hỏi và lựa chọn, gửi một phiếu bầu, và thấy xác nhận.

**Tại sao ưu tiên này**: Bỏ phiếu là tương tác cốt lõi - nếu không có khả năng bỏ phiếu, hệ thống poll không có mục đích. Đây là phần quan trọng thứ hai cần thiết cho MVP (tạo poll → bỏ phiếu poll).

**Kiểm Thử Độc Lập**: Có thể được kiểm tra độc lập bằng cách mở link poll `/polls/ABC123`, xem câu hỏi và lựa chọn, chọn một tùy chọn, nhấp "Gửi Phiếu Bầu", và nhận xác nhận "Phiếu bầu của bạn đã được ghi nhận". Mang lại giá trị: người tham gia có thể bày tỏ ý kiến ngay lập tức.

**Kịch Bản Chấp Nhận**:

1. **Cho trước** người tham gia mở link poll `/polls/ABC123`, **Khi** poll đang hoạt động (trước thời hạn), **Thì** người tham gia thấy câu hỏi poll, tất cả lựa chọn, và thời gian còn lại đến thời hạn
2. **Cho trước** người tham gia xem poll đang hoạt động, **Khi** người tham gia chọn một lựa chọn và nhấp "Gửi Phiếu Bầu", **Thì** phiếu bầu được ghi nhận và người tham gia thấy thông báo xác nhận "Cảm ơn bạn đã bỏ phiếu!"
3. **Cho trước** người tham gia đã bỏ phiếu poll ABC123, **Khi** người tham gia mở lại cùng link poll, **Thì** hệ thống hiển thị thông báo "Bạn đã bỏ phiếu poll này" và hiển thị lựa chọn trước đó của người tham gia
4. **Cho trước** người tham gia mở link poll sau khi thời hạn đã qua, **Khi** trang tải, **Thì** hệ thống hiển thị thông báo "Poll này đã đóng" và hiển thị kết quả cuối cùng
5. **Cho trước** người tham gia mở link poll không hợp lệ `/polls/INVALID`, **Khi** trang tải, **Thì** hệ thống hiển thị lỗi 404 "Không tìm thấy poll"

---

### User Story 3 - Hiển Thị Kết Quả Thời Gian Thực (Ưu Tiên: P2)

Người tạo poll và người tham gia xem kết quả bỏ phiếu theo thời gian thực với cập nhật trực tiếp khi có phiếu mới, với khả năng hiển thị được kiểm soát bởi cấu hình poll.

**Tại sao ưu tiên này**: Phản hồi thời gian thực tăng cường sự tham gia của người dùng và mang lại giá trị tức thì, nhưng hệ thống có thể hoạt động mà không có nó (kết quả có thể hiển thị sau thời hạn). Đây là một cải tiến có giá trị cho các story P1.

**Kiểm Thử Độc Lập**: Có thể được kiểm tra bằng cách tạo poll với "Hiển thị kết quả khi đang bỏ phiếu" được bật, mở poll trong hai cửa sổ trình duyệt, bỏ phiếu ở cửa sổ 1, và xác minh cửa sổ 2 cập nhật tự động không cần làm mới. Mang lại giá trị: minh bạch và tham gia trong giai đoạn bỏ phiếu.

**Kịch Bản Chấp Nhận**:

1. **Cho trước** người tạo poll tạo poll với cài đặt "Hiển thị kết quả khi đang bỏ phiếu: Có", **Khi** bất kỳ người tham gia nào bỏ phiếu, **Thì** tất cả người xem thấy số phiếu cập nhật ngay lập tức (trong vòng 2 giây) mà không cần làm mới trang
2. **Cho trước** người tạo poll tạo poll với cài đặt "Hiển thị kết quả khi đang bỏ phiếu: Không", **Khi** người tham gia đang bỏ phiếu, **Thì** số phiếu bị ẩn và chỉ hiển thị sau khi thời hạn qua
3. **Cho trước** người dùng đang xem trang kết quả poll, **Khi** số phiếu cập nhật, **Thì** thay đổi được làm nổi bật bằng hình ảnh (ví dụ: hiệu ứng động khi số tăng)
4. **Cho trước** poll đã nhận được phiếu bầu, **Khi** kết quả được hiển thị, **Thì** mỗi lựa chọn hiển thị số phiếu và phần trăm tổng số phiếu (ví dụ: "Pizza: 15 phiếu (45%)")
5. **Cho trước** thời hạn poll đã qua, **Khi** bất kỳ ai xem poll, **Thì** kết quả cuối cùng luôn hiển thị bất kể cài đặt "Hiển thị kết quả khi đang bỏ phiếu"

---

### User Story 4 - Quản Lý và Đóng Poll (Ưu Tiên: P3)

Người tạo poll có thể chỉnh sửa chi tiết poll trước khi có phiếu bầu nào được bỏ, đóng poll sớm thủ công, và xem thống kê cuối cùng sau thời hạn.

**Tại sao ưu tiên này**: Các tính năng quản lý cải thiện quyền kiểm soát của người tạo nhưng không cần thiết cho quy trình bỏ phiếu cốt lõi. Hệ thống mang lại giá trị đầy đủ chỉ với các story P1-P2.

**Kiểm Thử Độc Lập**: Có thể được kiểm tra bằng cách tạo poll, chỉnh sửa thời hạn trước khi có phiếu bầu (thành công), cố chỉnh sửa sau khi có phiếu bầu (bị chặn hoặc hạn chế), đóng poll thủ công trước thời hạn, và xem trang thống kê tổng hợp. Mang lại giá trị: tính linh hoạt cho người tạo poll.

**Kịch Bản Chấp Nhận**:

1. **Cho trước** người tạo poll đã tạo poll chưa có phiếu bầu, **Khi** người tạo nhấp "Chỉnh Sửa Poll", **Thì** người tạo có thể sửa đổi câu hỏi, lựa chọn, thời hạn, và cài đặt hiển thị
2. **Cho trước** poll đã nhận ít nhất một phiếu bầu, **Khi** người tạo cố chỉnh sửa lựa chọn poll, **Thì** hệ thống ngăn chặn thay đổi lựa chọn và hiển thị thông báo "Không thể sửa đổi lựa chọn sau khi phiếu bầu đã được ghi nhận"
3. **Cho trước** poll đang hoạt động với thời hạn ở tương lai, **Khi** người tạo nhấp "Đóng Poll Ngay", **Thì** poll ngay lập tức đóng và kết quả trở thành cuối cùng
4. **Cho trước** poll đã đóng (thời hạn qua hoặc đóng thủ công), **Khi** người tạo xem bảng điều khiển poll, **Thì** người tạo thấy thống kê: tổng số phiếu, phiếu cho mỗi lựa chọn, biểu đồ dòng thời gian bỏ phiếu (phiếu theo thời gian)
5. **Cho trước** người tạo xem thống kê poll, **Khi** trang tải, **Thì** người tạo thấy dữ liệu có thể xuất (nút tải CSV với các cột: Dấu Thời Gian, Lựa Chọn, Số Phiếu)

---

### Trường Hợp Biên

- Điều gì xảy ra khi thời hạn poll là chính xác lúc này (trong cùng giây)? → Poll đóng, không chấp nhận phiếu mới
- Hệ thống xử lý như thế nào khi người tham gia bỏ phiếu đúng lúc thời hạn? → Dấu thời gian phiếu so sánh với thời hạn; nếu phiếu được gửi trước khi thời hạn qua, nó được tính
- Điều gì xảy ra khi người tham gia mất kết nối internet trong quá trình gửi phiếu? → Gửi phiếu thất bại một cách nhẹ nhàng với thông báo lỗi "Mất kết nối. Vui lòng thử lại."
- Hệ thống xử lý như thế nào các phiếu bầu đồng thời từ những người tham gia khác nhau? → Cơ sở dữ liệu sử dụng giao dịch nguyên tử để đảm bảo đếm phiếu chính xác không có điều kiện chạy đua
- Điều gì xảy ra khi người tạo poll xóa poll mà người tham gia đang xem? → Người tham gia thấy thông báo "Poll không còn khả dụng"
- Hệ thống ngăn chặn thao túng phiếu bầu (bỏ phiếu nhiều lần) như thế nào? → Sử dụng dấu vân tay trình duyệt + theo dõi IP + cookie phiên (không xác thực); hoặc ID tài khoản người dùng nếu được xác thực
- Điều gì xảy ra khi poll có 0 phiếu và thời hạn qua? → Poll hiển thị thông báo "Không có phiếu bầu được ghi nhận" với tất cả lựa chọn ở 0%
- Hệ thống xử lý như thế nào câu hỏi poll hoặc văn bản lựa chọn cực kỳ dài? → Cắt ngắn hiển thị với "..." và hiển thị văn bản đầy đủ khi di chuột hoặc trong chế độ mở rộng
- Điều gì xảy ra khi poll có hơn 100 lựa chọn? → Hiển thị lựa chọn trong danh sách có thể cuộn hoặc chế độ phân trang; khuyến nghị chức năng tìm kiếm/lọc
- Hệ thống xử lý múi giờ cho thời hạn như thế nào? → Lưu trữ thời hạn ở UTC, hiển thị theo múi giờ địa phương của người tham gia với chỉ báo múi giờ rõ ràng

## Yêu Cầu *(bắt buộc)*

### Yêu Cầu Chức Năng

- **FR-001**: Hệ thống PHẢI cho phép người tạo poll tạo poll với câu hỏi (tối đa 500 ký tự), tối thiểu 2 lựa chọn (mỗi lựa chọn tối đa 200 ký tự), và thời hạn tương lai (ngày + giờ)
- **FR-002**: Hệ thống PHẢI tạo link chia sẻ duy nhất cho mỗi poll theo định dạng `/polls/[unique-code]` với mã là chữ và số, 6-8 ký tự, an toàn cho URL
- **FR-003**: Hệ thống PHẢI cho phép người tham gia gửi chính xác một phiếu bầu cho mỗi poll qua truy cập link (không yêu cầu xác thực cho MVP)
- **FR-004**: Hệ thống PHẢI ngăn chặn bỏ phiếu trùng lặp từ cùng người tham gia bằng cách sử dụng kết hợp phiên trình duyệt, cookie, và theo dõi địa chỉ IP
- **FR-005**: Hệ thống PHẢI tự động đóng poll khi đến thời hạn (không chấp nhận phiếu mới sau dấu thời gian thời hạn)
- **FR-006**: Hệ thống PHẢI hiển thị kết quả phiếu bầu với số phiếu và phần trăm cho mỗi lựa chọn, được định dạng "Tên Lựa Chọn: X phiếu (Y%)"
- **FR-007**: Hệ thống PHẢI hỗ trợ cập nhật kết quả thời gian thực bằng Turbo Streams (Rails 8 SSR) với cập nhật được đẩy trong vòng 2 giây sau khi gửi phiếu
- **FR-008**: Hệ thống PHẢI cho phép người tạo poll cấu hình khả năng hiển thị kết quả với hai tùy chọn: "Hiển thị kết quả khi đang bỏ phiếu" (Có/Không)
- **FR-009**: Hệ thống PHẢI hiển thị thời gian còn lại đến thời hạn ở định dạng dễ đọc (ví dụ: "còn 2 ngày 5 giờ")
- **FR-010**: Hệ thống PHẢI xác thực đầu vào tạo poll: câu hỏi bắt buộc, tối thiểu 2 lựa chọn, thời hạn phải là ngày tương lai
- **FR-011**: Hệ thống PHẢI hiển thị thông báo thích hợp cho poll đã đóng: "Poll này đã đóng. Kết quả:" theo sau là số phiếu cuối cùng
- **FR-012**: Hệ thống PHẢI lưu trữ tất cả phiếu bầu với dấu thời gian, ID lựa chọn, và mã định danh người tham gia (hash IP hoặc token phiên)
- **FR-013**: Hệ thống PHẢI ngăn chặn sửa đổi lựa chọn poll sau khi phiếu bầu đầu tiên được ghi nhận để duy trì tính toàn vẹn dữ liệu
- **FR-014**: Hệ thống PHẢI cho phép người tạo poll đóng poll thủ công trước thời hạn qua hành động "Đóng Poll Ngay"
- **FR-015**: Hệ thống PHẢI hiển thị thống kê poll cho người tạo bao gồm tổng số phiếu, phiếu cho mỗi lựa chọn, dòng thời gian tham gia (nếu được triển khai)

### Thực Thể Chính

- **Poll**: Đại diện cho poll bỏ phiếu với câu hỏi, thời hạn, cài đặt hiển thị (hiển thị kết quả khi đang bỏ phiếu), trạng thái (hoạt động/đã đóng), tham chiếu người tạo, mã truy cập duy nhất, dấu thời gian tạo
- **Choice**: Đại diện cho một tùy chọn trong poll; thuộc về một poll; có văn bản hiển thị, bộ nhớ đệm số phiếu, thứ tự hiển thị
- **Vote**: Đại diện cho phiếu bầu của một người tham gia; thuộc về một poll và một lựa chọn; có dấu thời gian, mã định danh người tham gia (hash IP hoặc token phiên), xác thực tính duy nhất cho mỗi kết hợp poll-người tham gia
- **Participant**: Thực thể ngầm định được theo dõi qua dấu vân tay trình duyệt/phiên (người dùng không xác thực); được xác định bằng tổ hợp hash của địa chỉ IP + user agent + cookie phiên

## Tiêu Chí Thành Công *(bắt buộc)*

### Kết Quả Có Thể Đo Lường

- **SC-001**: Người tạo poll có thể tạo và công bố poll trong vòng dưới 60 giây từ khi bắt đầu đến khi nhận link chia sẻ
- **SC-002**: Người tham gia có thể xem poll và gửi phiếu bầu trong vòng dưới 15 giây (không tính thời gian đọc poll)
- **SC-003**: Cập nhật kết quả thời gian thực xuất hiện trong vòng 2 giây sau khi gửi phiếu bầu cho tất cả người xem đang hoạt động
- **SC-004**: Hệ thống ngăn chặn bỏ phiếu trùng lặp chính xác với hiệu quả 99%+ (< 1% tỷ lệ phiếu trùng lặp qua vượt qua kỹ thuật)
- **SC-005**: Poll tự động đóng trong vòng 60 giây sau dấu thời gian thời hạn (độ trễ chấp nhận được cho xử lý công việc nền)
- **SC-006**: Hệ thống hỗ trợ ít nhất 100 người bỏ phiếu đồng thời trên một poll mà không suy giảm hiệu suất (thời gian phản hồi < 500ms cho p95)
- **SC-007**: Kết quả hiển thị chính xác với số phiếu và phần trăm chính xác (tổng tất cả phần trăm = 100% ± 0.1% làm tròn)
- **SC-008**: 95% người tạo poll chia sẻ link poll thành công và nhận được ít nhất một phiếu bầu (đo bằng phân tích)
- **SC-009**: Không mất dữ liệu cho phiếu bầu đã gửi trong điều kiện hoạt động bình thường (phiếu được lưu vào cơ sở dữ liệu trước khi hiển thị xác nhận)
- **SC-010**: Người dùng di động có thể tạo và bỏ phiếu poll với cùng chức năng như máy tính để bàn (thiết kế responsive, kiểm tra trên iOS/Android)

## Giả Định

- **Giả định 1**: Người tạo poll không yêu cầu xác thực cho MVP (bất kỳ ai cũng có thể tạo poll qua `/polls/new`)
- **Giả định 2**: Người tham gia không yêu cầu tài khoản; bỏ phiếu ẩn danh dựa trên truy cập link
- **Giả định 3**: Ngăn chặn phiếu bầu trùng lặp sử dụng dấu vân tay kỹ thuật (IP + phiên + cookie) thay vì xác thực người dùng
- **Giả định 4**: Poll vẫn có thể truy cập vô thời hạn sau khi tạo (không tự động xóa poll cũ)
- **Giả định 5**: Tối đa 50 lựa chọn cho mỗi poll (giới hạn UI hợp lý)
- **Giả định 6**: Tối đa 10.000 phiếu bầu cho mỗi poll (giả định khả năng mở rộng cơ sở dữ liệu)
- **Giả định 7**: Người tạo poll nhận link nhưng không yêu cầu hệ thống thông báo email cho MVP
- **Giả định 8**: Chuyển đổi hiển thị kết quả áp dụng cho giai đoạn trước thời hạn; tất cả poll hiển thị kết quả sau thời hạn
- **Giả định 9**: Không yêu cầu bảng điều khiển phân tích poll cho MVP (thống kê cơ bản hiển thị trên trang poll)
- **Giả định 10**: Giao diện tiếng Anh cho MVP (i18n có thể được thêm sau)

## Ngoài Phạm Vi

Các tính năng sau đây **không** được bao gồm rõ ràng trong đặc tả này:

- Xác thực người dùng và quản lý tài khoản (đăng nhập, đăng ký, hồ sơ)
- Thông báo Email/SMS cho tạo poll, bỏ phiếu, hoặc nhắc nhở thời hạn
- Mẫu poll hoặc gợi ý câu hỏi được điền sẵn
- Hỗ trợ đa ngôn ngữ (i18n)
- Hệ thống danh mục hoặc gắn thẻ poll
- Chức năng tìm kiếm để tìm poll công khai
- Tích hợp chia sẻ mạng xã hội (nút chia sẻ Twitter, Facebook)
- Bảng điều khiển phân tích nâng cao (nhân khẩu học người bỏ phiếu, biểu đồ chuỗi thời gian)
- Bình luận hoặc chủ đề thảo luận poll
- Hệ thống bỏ phiếu xếp hạng lựa chọn hoặc bỏ phiếu có trọng số
- Poll riêng tư yêu cầu mật khẩu hoặc truy cập danh sách trắng
- Chỉnh sửa poll sau khi phiếu bầu được ghi nhận (ngoài đóng thủ công)
- Định dạng xuất ngoài CSV (PDF, Excel, JSON)
- API cho tích hợp bên thứ ba
- Nhãn trắng hoặc tùy chọn thương hiệu tùy chỉnh
- Lưu trữ hoặc xóa poll của người tạo

## Ràng Buộc Kỹ Thuật

- Phải sử dụng Rails 8 với Hotwire/Turbo cho SSR và cập nhật thời gian thực (theo hiến pháp)
- Phải sử dụng PostgreSQL cho lưu trữ dữ liệu (theo hiến pháp)
- Phải sử dụng Solid Cache và Solid Queue (không yêu cầu Redis theo hiến pháp)
- Cập nhật thời gian thực qua Turbo Streams (không có thư viện WebSocket bên ngoài hệ sinh thái Rails)
- Thiết kế responsive với Tailwind CSS (cách tiếp cận mobile-first theo hiến pháp)
- Độ phủ kiểm thử tối thiểu 90% trên models và controllers (theo hiến pháp)
- Không có thư viện JavaScript bên ngoài ngoài mặc định importmap Rails (theo hiến pháp)
- Triển khai lên Render.com (theo hiến pháp và hướng dẫn RENDER.md)

## Phụ Thuộc

- Rails 8.1.2+ với Turbo Rails cho cập nhật SSR thời gian thực
- PostgreSQL 15+ cho lưu trữ dữ liệu quan hệ (polls, choices, votes)
- Solid Queue cho công việc nền đóng thời hạn (kiểm tra poll hết hạn mỗi phút)
- Tailwind CSS 4+ cho styling UI responsive
- Stimulus JS cho tương tác phía client (bộ đếm ngược, xử lý nút bỏ phiếu)
- Nền tảng triển khai Render.com (theo tiêu chuẩn dự án)

## Cân Nhắc Bảo Mật

- **Ngăn Chặn Phiếu Bầu Trùng Lặp**: Triển khai kiểm tra đa lớp (cookie phiên + hash IP + dấu vân tay trình duyệt) được lưu trong bảng votes
- **Giới Hạn Tỷ Lệ**: Ngăn chặn spam phiếu bầu bằng cách giới hạn phiếu bầu mỗi IP đến 10 phiếu/phút trên tất cả poll
- **Xác Thực Đầu Vào**: Làm sạch tất cả đầu vào người dùng (câu hỏi poll, văn bản lựa chọn) để ngăn chặn tấn công XSS
- **SQL Injection**: Sử dụng truy vấn tham số hóa Rails và Active Record độc quyền (theo hiến pháp)
- **Bảo Vệ CSRF**: Token CSRF tích hợp Rails được bật cho tất cả yêu cầu POST/PUT/DELETE (theo hiến pháp)
- **Truy Cập Poll**: Không yêu cầu xác thực nhưng mã duy nhất nên là ngẫu nhiên mật mã (SecureRandom.urlsafe_base64)
- **Quyền Riêng Tư Dữ Liệu**: Chỉ lưu trữ mã định danh người tham gia đã hash (hash SHA256 của IP + user agent), không phải địa chỉ IP thô
- **Tính Toàn Vẹn Thời Hạn**: Xác thực dấu thời gian phía server; không bao giờ tin tưởng dấu thời gian được gửi từ client

## Yêu Cầu Hiệu Suất

- **Thời Gian Tải Trang**: Trang xem poll tải trong < 1 giây (p95) với 10 lựa chọn và 100 phiếu
- **Gửi Phiếu Bầu**: Yêu cầu POST phiếu bầu hoàn thành trong < 300ms (p95) bao gồm xác thực và ghi cơ sở dữ liệu
- **Độ Trễ Cập Nhật Thời Gian Thực**: Phát sóng Turbo Stream đến các client được kết nối trong vòng 2 giây sau khi gửi phiếu bầu
- **Người Dùng Đồng Thời**: Hỗ trợ 100 người bỏ phiếu đồng thời trên poll đơn mà không suy giảm (kiểm tra qua kiểm thử tải)
- **Truy Vấn Cơ Sở Dữ Liệu**: Tránh truy vấn N+1 trên trang kết quả (sử dụng eager loading cho poll.choices.includes(:votes))
- **Caching**: Cache trang kết quả poll trong 5 giây (Solid Cache) để giảm tải cơ sở dữ liệu trên poll lưu lượng cao

## Yêu Cầu Khả Năng Tiếp Cận

- Tất cả biểu mẫu phải có nhãn và thuộc tính ARIA thích hợp cho trình đọc màn hình
- Hỗ trợ điều hướng bàn phím (thứ tự tab, enter để gửi phiếu bầu)
- Tỷ lệ tương phản màu đáp ứng tiêu chuẩn WCAG 2.1 AA (4.5:1 cho văn bản bình thường)
- Chỉ báo focus hiển thị trên tất cả các phần tử tương tác
- Thông báo lỗi được thông báo cho trình đọc màn hình
- Thiết kế responsive hỗ trợ zoom lên đến 200% mà không cuộn ngang

## Tóm Tắt Tiêu Chí Chấp Nhận

Tính năng này được coi là hoàn thành khi:

1. ✅ Người tạo poll có thể tạo poll với câu hỏi, ≥2 lựa chọn, thời hạn tương lai, nhận link chia sẻ
2. ✅ Người tham gia có thể bỏ phiếu qua link, gửi một phiếu bầu, thấy xác nhận
3. ✅ Hệ thống ngăn chặn phiếu bầu trùng lặp từ cùng người tham gia
4. ✅ Poll tự động đóng tại dấu thời gian thời hạn
5. ✅ Kết quả hiển thị với số phiếu và phần trăm
6. ✅ Cập nhật thời gian thực hoạt động qua Turbo Streams (< 2 giây độ trễ)
7. ✅ Người tạo poll có thể cấu hình khả năng hiển thị kết quả (hiện/ẩn khi đang bỏ phiếu)
8. ✅ Tất cả trường hợp biên được xử lý một cách nhẹ nhàng (poll đã đóng, link không hợp lệ, lỗi mạng)
9. ✅ Độ phủ kiểm thử ≥90% trên models và controllers
10. ✅ Thiết kế responsive hoạt động trên di động và máy tính để bàn
11. ✅ Tất cả yêu cầu chức năng (FR-001 đến FR-015) được triển khai
12. ✅ Tất cả tiêu chí thành công (SC-001 đến SC-010) được xác thực qua kiểm thử
