
## Tiếng việt

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
tao ra có thể xem lại ở tab **Review data **, hoặc bạn cũng có thể
download data này như là template để điền thông tin. Để download chọn
mục **Download template**.

Để xếp lịch, click vào **Optimize**, kết quả sẽ được trả về ở mục
**Schedule assign**.

### User data

Khi bạn đã hiểu cách app vận hành và muốn sử dụng data của mình, cách
tốt nhất là tải về template và chỉnh lại đúng ý mình. Lưu ý: app chỉ
nhận file .xlsx ở form tương tự như mục **Review data** với thông tin
của mỗi người nằm trong một sheet có tên của chính người đó. Ở ca không
ưu tiên nhất (Can’t work), hãy điền một ký tự bất kỳ (character)

Lưu ý:

-   Mặc định nhân viên không được làm hai ca trong một ngày.

-   Khi chạy trên random data, luôn **Generate data** trước khi
    **Optimize**.

## English
