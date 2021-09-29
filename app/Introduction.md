
## Tiếng việt

App source code:
[Github](https://github.com/vohai611/shiny-schedule-assign)

Xin chào!, đây là một application đơn giản giúp bạn sắp xếp lịch làm
việc cho nhân viên theo ca. App hoạt động dựa trên Linear programming.
Input là thông tin của mỗi nhân viên ở từng sheet, từng ngày. Mỗi ô có
giá trị 3,2,1 tương ứng với mức độ ưu tiên ( 3 là ưu tiên nhất). App sẽ
tối ưu tổng điểm ưu tiên của tất cả mọi người mà vẫn đảm bảo được:

-   Không ai làm hai ca trong một ngày

-   Một người có thể làm liên tục hai ngày hay không (mục **Allow work
    continously**)

-   Số nhân viên yêu cầu mỗi ca

### Random data

Trước tiên, hãy thử nghiệm với random data.

Có 4 thông số theo thứ tự:

-   Tổng số nhân viên

-   Số ngày lên lịch

-   Số ca làm việc trong một ngày.

-   Xác suât nhân viên bận

Sau khi chọn xong input data, click vào mục **Generate data**. Data được
tao ra có thể xem lại ở tab **Review data**, hoặc bạn cũng có thể
download data này như là template để điền thông tin.

-   Để download chọn mục: **Download template**.

-   Để xếp lịch, click vào **Optimize**, kết quả sẽ được trả về ở mục
    **Schedule assign**.

### Data của bạn

Khi bạn đã hiểu cách app vận hành và muốn sử dụng data của mình, cách
tốt nhất là tải về template và chỉnh lại đúng ý mình.

App chỉ nhận file .xlsx ở form tương tự như mục **Review data** với
thông tin của mỗi người nằm trong một sheet có tên của chính người đó. Ở
random data, thang điểm ưu tiên là 1-3, tuy nhiên bạn hoàn toàn có thể
chọn thang điểm khác (vd 1-10). Ở ca không ưu tiên nhất (Busy), hãy điền
một ký tự bất kỳ (character)

Lưu ý:

-   Mặc định nhân viên không được làm hai ca trong một ngày.

-   Luôn luôn **Generate data** trước khi **Optimize**.

Nếu bạn có bất kỳ vấn đề , hay câu hỏi nào liên quan đến app, hãy [open
github issues](https://github.com/vohai611/shiny-schedule-assign/issues)

## English
