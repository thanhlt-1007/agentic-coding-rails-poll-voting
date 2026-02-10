# Kế Hoạch Triển Khai: Hệ Thống Bỏ Phiếu

**Nhánh**: `001-poll-voting-system` | **Ngày**: 10 tháng 2, 2026 | **Đặc tả**: [spec.en.md](spec.en.md) | [spec.vi.md](spec.vi.md)  
**Đầu vào**: Đặc tả tính năng từ `/specs/001-poll-voting-system/spec.en.md`

## Tóm Tắt

Xây dựng hệ thống bỏ phiếu cho phép người tạo tạo các cuộc thăm dò với câu hỏi, nhiều lựa chọn và thời hạn. Người tham gia bỏ phiếu thông qua liên kết chia sẻ (một phiếu mỗi cuộc thăm dò), với kết quả thời gian thực hiển thị dựa trên cấu hình. Cuộc thăm dò tự động đóng khi hết hạn. Phương pháp kỹ thuật sử dụng Rails 8 với Hotwire/Turbo cho SSR và cập nhật thời gian thực, PostgreSQL cho lưu trữ dữ liệu, Solid Queue cho quản lý thời hạn, và dấu vân tay trình duyệt để ngăn chặn bỏ phiếu trùng lặp.

## Bối Cảnh Kỹ Thuật

**Ngôn ngữ/Phiên bản**: Ruby 4.0.1, Rails 8.1.2  
**Phụ thuộc chính**: Turbo Rails (Hotwire), Stimulus JS, Tailwind CSS 4+, Solid Queue, Solid Cache, Solid Cable  
**Lưu trữ**: PostgreSQL 15+ (bảng polls, choices, votes)  
**Kiểm thử**: Minitest (mặc định Rails), Capybara (kiểm thử hệ thống), FactoryBot (dữ liệu kiểm thử)  
**Nền tảng mục tiêu**: Ứng dụng web (responsive desktop + mobile), triển khai lên Render.com  
**Loại dự án**: Rails monolith với kiến trúc SSR-first  
**Mục tiêu hiệu năng**: Tạo cuộc thăm dò < 60s, bỏ phiếu < 15s, cập nhật thời gian thực < 2s độ trễ, 100+ người bỏ phiếu đồng thời mỗi cuộc thăm dò  
**Ràng buộc**: <500ms p95 thời gian phản hồi, <200ms gửi phiếu, thời gian thực chỉ qua Turbo Streams (không thư viện WebSocket bên ngoài), 90%+ độ bao phủ kiểm thử  
**Quy mô/Phạm vi**: MVP hỗ trợ số cuộc thăm dò không giới hạn, 10k phiếu/cuộc thăm dò, 50 lựa chọn/cuộc thăm dò, người tham gia ẩn danh (không xác thực)

## Kiểm Tra Hiến Pháp

*CỔNG: Phải vượt qua trước Giai đoạn 0 nghiên cứu. Kiểm tra lại sau Giai đoạn 1 thiết kế.*

✅ **Kiến trúc Rails-First**: Sử dụng quy ước Rails 8 (generators, MVC, Active Record, Turbo, ViewComponents)  
✅ **TDD KHÔNG THỂ THƯƠNG LƯỢNG**: Minitest với 90%+ độ bao phủ, viết kiểm thử trước khi triển khai  
✅ **Hiệu năng SSR**: Turbo Streams cho cập nhật thời gian thực, fragment caching, eager loading để ngăn N+1  
✅ **Bảo mật theo mặc định**: Strong parameters, bảo vệ CSRF, ngăn XSS, ngăn SQL injection qua AR  
✅ **Đơn giản & Dễ bảo trì**: Không thư viện JavaScript bên ngoài ngoài importmap mặc định, chỉ mẫu Rails  
✅ **PostgreSQL 15+**: Theo hiến pháp  
✅ **Solid Queue/Cache/Cable**: Theo hiến pháp (không cần Redis)  
✅ **Tailwind CSS**: Theo hiến pháp  
✅ **Triển khai**: Render.com theo hiến pháp và hướng dẫn RENDER.md  

**Tuân thủ Hiến pháp**: ✅ ĐẠT - Không vi phạm, tất cả yêu cầu phù hợp với hiến pháp

## Cấu Trúc Dự Án

### Tài liệu (tính năng này)

```text
specs/001-poll-voting-system/
├── spec.en.md           # Đặc tả tiếng Anh (nguồn chân lý)
├── spec.vi.md           # Đặc tả tiếng Việt (bản dịch)
├── plan.en.md           # Kế hoạch kỹ thuật tiếng Anh
├── plan.vi.md           # File này (kế hoạch kỹ thuật tiếng Việt)
├── checklists/
│   └── requirements.md  # Danh sách kiểm tra xác thực đặc tả
└── research.md          # Đầu ra Giai đoạn 0 (nếu cần)
```

### Mã nguồn (cấu trúc Rails monolith)

```text
app/
├── models/
│   ├── poll.rb              # Model Poll (question, deadline, status, access_code)
│   ├── choice.rb            # Model Choice (belongs_to :poll, has_many :votes)
│   ├── vote.rb              # Model Vote (belongs_to :choice, :poll, người tham gia duy nhất)
│   └── concerns/
│       └── votable.rb       # Logic bỏ phiếu chung (nếu cần)
├── controllers/
│   ├── polls_controller.rb  # CRUD cho polls (new, create, show, edit, update, close)
│   └── votes_controller.rb  # Endpoint bỏ phiếu (create, xác thực ngăn trùng lặp)
├── views/
│   ├── polls/
│   │   ├── new.html.erb     # Form tạo cuộc thăm dò
│   │   ├── show.html.erb    # Hiển thị cuộc thăm dò + giao diện bỏ phiếu
│   │   ├── edit.html.erb    # Chỉnh sửa cuộc thăm dò (chỉ trước khi có phiếu)
│   │   ├── _form.html.erb   # Partial form cuộc thăm dò
│   │   └── _results.html.erb # Partial kết quả (cho cập nhật Turbo Stream)
│   └── votes/
│       └── _confirmation.html.erb # Thông báo xác nhận bỏ phiếu
├── javascript/
│   └── controllers/
│       ├── countdown_controller.js  # Stimulus: bộ đếm ngược thời hạn
│       └── vote_controller.js       # Stimulus: xử lý nút bỏ phiếu
├── jobs/
│   └── close_expired_polls_job.rb   # Solid Queue: đóng cuộc thăm dò hết hạn
└── helpers/
    └── polls_helper.rb              # Định dạng thời gian, tính phần trăm

config/
├── routes.rb                # Routes Poll: resources :polls, nested votes
└── initializers/
    └── solid_queue.rb       # Cấu hình Solid Queue cho công việc định kỳ

db/
├── migrate/
│   ├── [timestamp]_create_polls.rb
│   ├── [timestamp]_create_choices.rb
│   └── [timestamp]_create_votes.rb
└── schema.rb                # Schema tự động sinh

test/
├── models/
│   ├── poll_test.rb         # Xác thực Poll, liên kết, logic nghiệp vụ
│   ├── choice_test.rb       # Xác thực Choice, đếm phiếu
│   └── vote_test.rb         # Ngăn trùng lặp, xác thực timestamp
├── controllers/
│   ├── polls_controller_test.rb  # Kiểm thử request cho CRUD poll
│   └── votes_controller_test.rb  # Kiểm thử request cho bỏ phiếu
├── system/
│   ├── create_poll_test.rb       # E2E: Tạo cuộc thăm dò, nhận liên kết
│   ├── vote_on_poll_test.rb      # E2E: Bỏ phiếu, xem xác nhận
│   ├── real_time_results_test.rb # E2E: Cập nhật thời gian thực qua Turbo
│   └── poll_closure_test.rb      # E2E: Thực thi thời hạn
└── factories/
    ├── polls.rb
    ├── choices.rb
    └── votes.rb
```

**Quyết định Cấu trúc**: Rails monolith với kiến trúc MVC chuẩn. Tất cả mã trong `app/` theo quy ước Rails. Turbo Streams xử lý cập nhật thời gian thực phía server (không build frontend riêng). Công việc nền Solid Queue cho quản lý thời hạn. Kiểm thử được tổ chức theo loại (models, controllers, system).

## Theo Dõi Độ Phức Tạp

**Không vi phạm hiến pháp** - đây là ứng dụng Rails đơn giản tuân theo tất cả nguyên tắc hiến pháp. Không cần biện minh độ phức tạp.

## Lược Đồ Cơ Sở Dữ Liệu

### Bảng Polls

```ruby
# db/migrate/[timestamp]_create_polls.rb
create_table :polls do |t|
  t.string :question, null: false, limit: 500
  t.datetime :deadline, null: false
  t.string :access_code, null: false, limit: 8, index: { unique: true }
  t.boolean :show_results_while_voting, default: false, null: false
  t.string :status, default: 'active', null: false # active, closed
  t.integer :total_votes, default: 0, null: false # Cache cho hiệu năng
  
  t.timestamps
  
  # Chỉ mục
  t.index :status
  t.index :deadline
end

# Xác thực (trong poll.rb)
validates :question, presence: true, length: { maximum: 500 }
validates :deadline, presence: true
validate :deadline_must_be_in_future, on: :create
validates :access_code, presence: true, uniqueness: true
validates :status, inclusion: { in: %w[active closed] }
has_many :choices, dependent: :destroy
has_many :votes, through: :choices
accepts_nested_attributes_for :choices, reject_if: :all_blank

# Phương thức tùy chỉnh
def active?
  status == 'active' && deadline > Time.current
end

def closed?
  status == 'closed' || deadline <= Time.current
end

def close!
  update!(status: 'closed')
end

before_create :generate_access_code

private

def generate_access_code
  self.access_code = SecureRandom.urlsafe_base64(6).upcase[0..7]
end

def deadline_must_be_in_future
  errors.add(:deadline, "phải trong tương lai") if deadline.present? && deadline <= Time.current
end
```

### Bảng Choices

```ruby
# db/migrate/[timestamp]_create_choices.rb
create_table :choices do |t|
  t.references :poll, null: false, foreign_key: true, index: true
  t.string :text, null: false, limit: 200
  t.integer :position, default: 0, null: false
  t.integer :votes_count, default: 0, null: false # Counter cache
  
  t.timestamps
  
  # Chỉ mục
  t.index [:poll_id, :position]
end

# Xác thực (trong choice.rb)
belongs_to :poll
has_many :votes, dependent: :destroy
validates :text, presence: true, length: { maximum: 200 }
validates :poll_id, presence: true

# Cập nhật counter cache
after_create :update_poll_total_votes
after_destroy :update_poll_total_votes

def percentage
  return 0 if poll.total_votes.zero?
  (votes_count.to_f / poll.total_votes * 100).round(1)
end
```

### Bảng Votes

```ruby
# db/migrate/[timestamp]_create_votes.rb
create_table :votes do |t|
  t.references :poll, null: false, foreign_key: true, index: true
  t.references :choice, null: false, foreign_key: true, index: true
  t.string :participant_fingerprint, null: false, limit: 64 # SHA256 hash
  t.string :ip_hash, null: false, limit: 64 # SHA256 của IP
  t.string :session_token, limit: 64 # Định danh session
  t.datetime :voted_at, null: false
  
  t.timestamps
  
  # Chỉ mục unique tổng hợp để ngăn phiếu trùng lặp
  t.index [:poll_id, :participant_fingerprint], unique: true, name: 'index_votes_on_poll_and_participant'
  t.index :voted_at
  t.index :ip_hash
end

# Xác thực (trong vote.rb)
belongs_to :poll, counter_cache: :total_votes
belongs_to :choice, counter_cache: :votes_count
validates :poll_id, presence: true
validates :choice_id, presence: true
validates :participant_fingerprint, presence: true, uniqueness: { scope: :poll_id }
validates :voted_at, presence: true
validate :poll_must_be_active
validate :deadline_not_passed

before_validation :set_voted_at, :generate_fingerprint

private

def set_voted_at
  self.voted_at ||= Time.current
end

def generate_fingerprint
  # Kết hợp IP + User-Agent + Session để nhận dạng duy nhất
  data = "#{ip_hash}-#{request.user_agent}-#{session_token}"
  self.participant_fingerprint = Digest::SHA256.hexdigest(data)
end

def poll_must_be_active
  errors.add(:poll, "phải đang hoạt động") unless poll&.active?
end

def deadline_not_passed
  errors.add(:base, "Cuộc thăm dò đã đóng") if poll && poll.deadline <= Time.current
end
```

## Cấu Hình Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "welcome#index" # Trang chào mừng hiện tại
  
  resources :polls, param: :access_code, only: [:new, :create, :show, :edit, :update] do
    member do
      patch :close  # Hành động đóng thủ công
    end
    
    resources :votes, only: [:create], shallow: true
  end
  
  # Kiểm tra sức khỏe cho Render.com
  get "up" => "rails/health#show", as: :rails_health_check
end

# Routes được tạo:
# GET    /polls/new                → polls#new      (form tạo cuộc thăm dò)
# POST   /polls                    → polls#create   (tạo cuộc thăm dò)
# GET    /polls/:access_code       → polls#show     (xem cuộc thăm dò + giao diện bỏ phiếu)
# GET    /polls/:access_code/edit  → polls#edit     (chỉnh sửa cuộc thăm dò - chỉ trước phiếu)
# PATCH  /polls/:access_code       → polls#update   (cập nhật cuộc thăm dò)
# PATCH  /polls/:access_code/close → polls#close    (đóng thủ công)
# POST   /polls/:poll_access_code/votes → votes#create (gửi phiếu)
```

## Triển Khai Controllers

### PollsController

```ruby
class PollsController < ApplicationController
  before_action :set_poll, only: [:show, :edit, :update, :close]
  
  def new
    @poll = Poll.new
    3.times { @poll.choices.build } # Bắt đầu với 3 lựa chọn trống
  end
  
  def create
    @poll = Poll.new(poll_params)
    
    if @poll.save
      redirect_to poll_path(@poll.access_code), notice: "Cuộc thăm dò đã tạo! Chia sẻ liên kết này với người tham gia."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @vote = Vote.new(poll: @poll)
    @participant_voted = @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
    
    if @participant_voted
      @participant_vote = @poll.votes.find_by(participant_fingerprint: current_participant_fingerprint)
    end
  end
  
  def edit
    if @poll.votes.any?
      redirect_to poll_path(@poll.access_code), alert: "Không thể chỉnh sửa cuộc thăm dò sau khi có phiếu bầu."
    end
  end
  
  def update
    if @poll.votes.any?
      redirect_to poll_path(@poll.access_code), alert: "Không thể sửa đổi cuộc thăm dò sau khi có phiếu bầu."
      return
    end
    
    if @poll.update(poll_params)
      redirect_to poll_path(@poll.access_code), notice: "Cuộc thăm dò đã cập nhật thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def close
    @poll.close!
    redirect_to poll_path(@poll.access_code), notice: "Cuộc thăm dò đã đóng thành công."
  end
  
  private
  
  def set_poll
    @poll = Poll.find_by!(access_code: params[:access_code])
  end
  
  def poll_params
    params.require(:poll).permit(
      :question, :deadline, :show_results_while_voting,
      choices_attributes: [:id, :text, :position, :_destroy]
    )
  end
  
  def current_participant_fingerprint
    data = "#{request.remote_ip}-#{request.user_agent}-#{session.id}"
    Digest::SHA256.hexdigest(data)
  end
end
```

### VotesController

```ruby
class VotesController < ApplicationController
  before_action :set_poll
  before_action :check_duplicate_vote
  
  def create
    @vote = @poll.votes.new(vote_params)
    @vote.ip_hash = Digest::SHA256.hexdigest(request.remote_ip)
    @vote.session_token = session.id
    @vote.participant_fingerprint = current_participant_fingerprint
    
    if @vote.save
      # Phát cập nhật thời gian thực qua Turbo Stream
      broadcast_vote_update
      
      respond_to do |format|
        format.html { redirect_to poll_path(@poll.access_code), notice: "Cảm ơn bạn đã bỏ phiếu!" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to poll_path(@poll.access_code), alert: @vote.errors.full_messages.join(", ") }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("vote-form", partial: "votes/error", locals: { errors: @vote.errors }) }
      end
    end
  end
  
  private
  
  def set_poll
    @poll = Poll.find_by!(access_code: params[:poll_access_code])
  end
  
  def check_duplicate_vote
    if @poll.votes.exists?(participant_fingerprint: current_participant_fingerprint)
      redirect_to poll_path(@poll.access_code), alert: "Bạn đã bỏ phiếu trong cuộc thăm dò này."
    end
  end
  
  def vote_params
    params.require(:vote).permit(:choice_id)
  end
  
  def current_participant_fingerprint
    data = "#{request.remote_ip}-#{request.user_agent}-#{session.id}"
    Digest::SHA256.hexdigest(data)
  end
  
  def broadcast_vote_update
    # Phát tới tất cả người xem cuộc thăm dò này
    broadcast_replace_to [@poll, :results],
      target: "poll-results",
      partial: "polls/results",
      locals: { poll: @poll.reload }
  end
end
```

## Cập Nhật Thời Gian Thực (Turbo Streams)

### Thiết Lập View

```erb
<!-- app/views/polls/show.html.erb -->
<div class="poll-container">
  <%= turbo_stream_from [@poll, :results] %>
  
  <h1><%= @poll.question %></h1>
  
  <% if @poll.closed? %>
    <p class="alert alert-info">Cuộc thăm dò này đã đóng. Kết quả:</p>
  <% elsif @participant_voted %>
    <p class="alert alert-success">Bạn đã bỏ phiếu trong cuộc thăm dò này.</p>
  <% else %>
    <p class="countdown" data-controller="countdown" data-countdown-deadline-value="<%= @poll.deadline.iso8601 %>">
      Thời gian còn lại: <span data-countdown-target="display"></span>
    </p>
  <% end %>
  
  <%= turbo_frame_tag "vote-form" do %>
    <% unless @participant_voted || @poll.closed? %>
      <%= render "votes/form", poll: @poll, vote: @vote %>
    <% end %>
  <% end %>
  
  <div id="poll-results">
    <%= render "polls/results", poll: @poll %>
  </div>
</div>
```

```erb
<!-- app/views/polls/_results.html.erb -->
<% if poll.show_results_while_voting || poll.closed? %>
  <div class="results">
    <h2>Kết quả</h2>
    <% poll.choices.each do |choice| %>
      <div class="choice-result">
        <span class="choice-text"><%= choice.text %></span>
        <div class="vote-bar" style="width: <%= choice.percentage %>%"></div>
        <span class="vote-count"><%= choice.votes_count %> phiếu (<%= choice.percentage %>%)</span>
      </div>
    <% end %>
    <p class="total-votes">Tổng số phiếu: <%= poll.total_votes %></p>
  </div>
<% else %>
  <p class="text-muted">Kết quả sẽ hiển thị sau khi cuộc thăm dò đóng.</p>
<% end %>
```

### Stimulus Controller cho Đếm Ngược

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { deadline: String }
  
  connect() {
    this.updateCountdown()
    this.interval = setInterval(() => this.updateCountdown(), 1000)
  }
  
  disconnect() {
    clearInterval(this.interval)
  }
  
  updateCountdown() {
    const now = new Date()
    const deadline = new Date(this.deadlineValue)
    const diff = deadline - now
    
    if (diff <= 0) {
      this.displayTarget.textContent = "Cuộc thăm dò đã đóng"
      clearInterval(this.interval)
      window.location.reload() // Tải lại để hiển thị trạng thái đã đóng
      return
    }
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)
    
    let display = ""
    if (days > 0) display += `${days} ngày `
    if (hours > 0 || days > 0) display += `${hours} giờ `
    display += `${minutes} phút ${seconds} giây`
    
    this.displayTarget.textContent = display
  }
}
```

## Công Việc Nền (Solid Queue)

### Công Việc Đóng Cuộc Thăm Dò Hết Hạn

```ruby
# app/jobs/close_expired_polls_job.rb
class CloseExpiredPollsJob < ApplicationJob
  queue_as :default
  
  def perform
    expired_polls = Poll.where(status: 'active').where('deadline <= ?', Time.current)
    
    expired_polls.find_each do |poll|
      poll.close!
      
      # Phát thông báo đóng tới tất cả người xem
      broadcast_replace_to [poll, :results],
        target: "poll-results",
        partial: "polls/results",
        locals: { poll: poll }
      
      Rails.logger.info "Đã đóng cuộc thăm dò #{poll.access_code} (ID: #{poll.id})"
    end
    
    Rails.logger.info "Đã xử lý #{expired_polls.count} cuộc thăm dò hết hạn"
  end
end
```

### Cấu Hình Solid Queue

```ruby
# config/initializers/solid_queue.rb
Rails.application.config.after_initialize do
  if defined?(SolidQueue)
    # Lên lịch công việc định kỳ kiểm tra cuộc thăm dò hết hạn mỗi phút
    SolidQueue::RecurringTask.create_or_find_by!(
      key: "close_expired_polls",
      class_name: "CloseExpiredPollsJob",
      schedule: "every minute"
    )
  end
end
```

## Chiến Lược Kiểm Thử

### Kiểm Thử Model

```ruby
# test/models/poll_test.rb
require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "không nên lưu cuộc thăm dò không có câu hỏi" do
    poll = Poll.new(deadline: 1.day.from_now)
    assert_not poll.save, "Đã lưu cuộc thăm dò không có câu hỏi"
  end
  
  test "không nên lưu cuộc thăm dò với thời hạn trong quá khứ" do
    poll = Poll.new(question: "Thử nghiệm?", deadline: 1.day.ago)
    assert_not poll.save, "Đã lưu cuộc thăm dò với thời hạn quá khứ"
  end
  
  test "nên tạo mã truy cập duy nhất khi tạo" do
    poll = Poll.create!(question: "Thử nghiệm?", deadline: 1.day.from_now)
    assert_not_nil poll.access_code
    assert_equal 8, poll.access_code.length
  end
  
  test "nên yêu cầu tối thiểu 2 lựa chọn" do
    poll = Poll.new(question: "Thử nghiệm?", deadline: 1.day.from_now)
    poll.choices.build(text: "Chỉ một")
    assert_not poll.save, "Đã lưu cuộc thăm dò chỉ có 1 lựa chọn"
  end
  
  test "active? nên trả về true cho cuộc thăm dò hoạt động trước thời hạn" do
    poll = create(:poll, status: 'active', deadline: 1.day.from_now)
    assert poll.active?
  end
  
  test "closed? nên trả về true sau thời hạn" do
    poll = create(:poll, deadline: 1.hour.ago)
    assert poll.closed?
  end
end

# test/models/vote_test.rb
require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "nên ngăn phiếu trùng lặp từ cùng người tham gia" do
    poll = create(:poll)
    choice = create(:choice, poll: poll)
    fingerprint = "abc123"
    
    vote1 = Vote.create!(poll: poll, choice: choice, participant_fingerprint: fingerprint)
    vote2 = Vote.new(poll: poll, choice: choice, participant_fingerprint: fingerprint)
    
    assert_not vote2.save, "Đã lưu phiếu trùng lặp"
  end
  
  test "không nên cho phép bỏ phiếu trong cuộc thăm dò đã đóng" do
    poll = create(:poll, status: 'closed')
    choice = create(:choice, poll: poll)
    vote = Vote.new(poll: poll, choice: choice, participant_fingerprint: "abc123")
    
    assert_not vote.save, "Đã bỏ phiếu trong cuộc thăm dò đã đóng"
  end
  
  test "nên tăng counter caches" do
    poll = create(:poll)
    choice = create(:choice, poll: poll)
    
    assert_difference 'choice.reload.votes_count', 1 do
      assert_difference 'poll.reload.total_votes', 1 do
        create(:vote, poll: poll, choice: choice)
      end
    end
  end
end
```

### Kiểm Thử Hệ Thống

```ruby
# test/system/create_poll_test.rb
require "application_system_test_case"

class CreatePollTest < ApplicationSystemTestCase
  test "tạo cuộc thăm dò với dữ liệu hợp lệ" do
    visit new_poll_path
    
    fill_in "Câu hỏi", with: "Màu sắc yêu thích của bạn là gì?"
    fill_in "poll_choices_attributes_0_text", with: "Đỏ"
    fill_in "poll_choices_attributes_1_text", with: "Xanh dương"
    fill_in "poll_choices_attributes_2_text", with: "Xanh lá"
    fill_in "Thời hạn", with: 1.day.from_now
    
    click_button "Tạo Cuộc Thăm Dò"
    
    assert_text "Cuộc thăm dò đã tạo!"
    assert_current_path /\/polls\/[A-Z0-9]{8}/
  end
  
  test "hiển thị lỗi xác thực cho cuộc thăm dò không hợp lệ" do
    visit new_poll_path
    
    # Chỉ thêm 1 lựa chọn (tối thiểu là 2)
    fill_in "poll_choices_attributes_0_text", with: "Chỉ một"
    fill_in "Thời hạn", with: 1.day.from_now
    
    click_button "Tạo Cuộc Thăm Dò"
    
    assert_text "phải có ít nhất 2 lựa chọn"
  end
end

# test/system/vote_on_poll_test.rb
require "application_system_test_case"

class VoteOnPollTest < ApplicationSystemTestCase
  test "bỏ phiếu trong cuộc thăm dò đang hoạt động" do
    poll = create(:poll, :with_choices)
    
    visit poll_path(poll.access_code)
    
    assert_text poll.question
    choose poll.choices.first.text
    click_button "Gửi Phiếu"
    
    assert_text "Cảm ơn bạn đã bỏ phiếu!"
    assert_text "Bạn đã bỏ phiếu trong cuộc thăm dò này"
  end
  
  test "không thể bỏ phiếu hai lần trong cùng cuộc thăm dò" do
    poll = create(:poll, :with_choices)
    create(:vote, poll: poll, choice: poll.choices.first, participant_fingerprint: "test123")
    
    # Giả lập cùng người tham gia
    using_session("test123") do
      visit poll_path(poll.access_code)
      
      assert_text "Bạn đã bỏ phiếu trong cuộc thăm dò này"
      assert_no_button "Gửi Phiếu"
    end
  end
  
  test "hiển thị thông báo đã đóng sau thời hạn" do
    poll = create(:poll, :closed)
    
    visit poll_path(poll.access_code)
    
    assert_text "Cuộc thăm dò này đã đóng"
    assert_no_button "Gửi Phiếu"
  end
end
```

## Triển Khai Bảo Mật

### Ngăn Chặn Bỏ Phiếu Trùng Lặp

```ruby
# app/controllers/concerns/participant_identification.rb
module ParticipantIdentification
  extend ActiveSupport::Concern
  
  private
  
  def current_participant_fingerprint
    # Dấu vân tay đa lớp
    components = [
      request.remote_ip,
      request.user_agent || 'unknown',
      session.id.to_s
    ]
    
    Digest::SHA256.hexdigest(components.join('-'))
  end
  
  def participant_ip_hash
    Digest::SHA256.hexdigest(request.remote_ip)
  end
end
```

### Giới Hạn Tốc Độ (Rack::Attack)

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Giới hạn nỗ lực bỏ phiếu
  throttle('votes/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path.include?('/votes') && req.post?
  end
  
  # Giới hạn tạo cuộc thăm dò
  throttle('polls/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/polls' && req.post?
  end
end
```

## Tối Ưu Hiệu Năng

### Chỉ Mục Cơ Sở Dữ Liệu

```ruby
# Đã bao gồm trong schema ở trên:
# - access_code (chỉ mục duy nhất)
# - poll_id, participant_fingerprint (tổng hợp duy nhất)
# - cột counter_cache (votes_count, total_votes)
# - status, deadline (cho truy vấn job)
```

### Tối Ưu Truy Vấn

```ruby
# Trong PollsController#show
def show
  @poll = Poll.includes(choices: :votes).find_by!(access_code: params[:access_code])
  # Eager load choices và votes để ngăn N+1
end
```

### Chiến Lược Caching

```ruby
# Trong polls/_results.html.erb
<% cache [@poll, @poll.updated_at, "results"] do %>
  <!-- HTML kết quả -->
<% end %>

# Fragment cache invalidation tự động qua updated_at touch
```

## Cấu Hình Triển Khai

### Thứ Tự Migrations Cơ Sở Dữ Liệu

1. `rails generate migration CreatePolls`
2. `rails generate migration CreateChoices`
3. `rails generate migration CreateVotes`
4. `rails db:migrate`

### Biến Môi Trường (Render.com)

Theo RENDER.md và hiến pháp:
- `DATABASE_URL` (tự động cung cấp bởi Render.com)
- `REDIS_URL` (tự động cung cấp, mặc dù Solid Queue không cần)
- `RAILS_MASTER_KEY` (cấu hình thủ công)
- `RAILS_ENV=production`
- `RAILS_LOG_LEVEL=info`
- `RAILS_FORCE_SSL=true`

### Lệnh Build

```bash
bundle install && bundle exec rails assets:precompile && bundle exec rails db:prepare
```

### Lệnh Start

```bash
bundle exec rails server -b 0.0.0.0
```

## Các Giai Đoạn Triển Khai

### Giai đoạn 1: Models & Database Cốt Lõi (P1 - Nền tảng)

**Thời gian**: 1-2 ngày  
**Sản phẩm**:
- [ ] Tạo migrations cho bảng polls, choices, votes
- [ ] Triển khai model Poll với validations, associations
- [ ] Triển khai model Choice với counter cache
- [ ] Triển khai model Vote với ngăn chặn trùng lặp
- [ ] Viết kiểm thử model (90%+ coverage)
- [ ] Chạy migrations, xác minh schema

**Kiểm thử**:
- Kiểm thử đơn vị model cho validations
- Kiểm thử liên kết
- Kiểm thử counter cache
- Kiểm thử ràng buộc duy nhất

### Giai đoạn 2: Tạo & Hiển Thị Poll (P1 - MVP Slice 1)

**Thời gian**: 2-3 ngày  
**Sản phẩm**:
- [ ] Tạo PollsController với actions new, create, show
- [ ] Tạo view form poll với nested choices
- [ ] Triển khai tạo access code
- [ ] Thêm cấu hình routes
- [ ] Triển khai trang hiển thị poll
- [ ] Viết controller và system tests

**Kiểm thử**:
- Request tests cho CRUD poll
- System test: tạo poll, nhận liên kết
- System test: xem poll qua access code
- Kiểm thử xử lý lỗi validation

### Giai đoạn 3: Chức Năng Bỏ Phiếu (P1 - MVP Slice 2)

**Thời gian**: 2-3 ngày  
**Sản phẩm**:
- [ ] Tạo VotesController với action create
- [ ] Triển khai dấu vân tay người tham gia
- [ ] Thêm kiểm tra phiếu trùng lặp
- [ ] Tạo form bỏ phiếu và views xác nhận
- [ ] Triển khai validation vote
- [ ] Viết controller và system tests

**Kiểm thử**:
- Request tests cho bỏ phiếu
- System test: gửi phiếu, xem xác nhận
- System test: ngăn chặn phiếu trùng lặp
- System test: bỏ phiếu trong poll đã đóng (nên thất bại)

### Giai đoạn 4: Cập Nhật Thời Gian Thực (P2 - Nâng cao)

**Thời gian**: 2-3 ngày  
**Sản phẩm**:
- [ ] Triển khai broadcasts Turbo Stream
- [ ] Thêm partial kết quả với phần trăm phiếu
- [ ] Tạo Stimulus countdown controller
- [ ] Triển khai logic hiện/ẩn kết quả
- [ ] Thêm cập nhật kết quả thời gian thực
- [ ] Viết system tests cho tính năng thời gian thực

**Kiểm thử**:
- System test: cập nhật thời gian thực (2 cửa sổ trình duyệt)
- System test: cấu hình hiển thị kết quả
- Kiểm thử JavaScript controller

### Giai đoạn 5: Quản Lý Poll (P3 - Tùy chọn)

**Thời gian**: 1-2 ngày  
**Sản phẩm**:
- [ ] Triển khai actions edit/update (chỉ trước phiếu)
- [ ] Thêm action đóng thủ công
- [ ] Tạo view thống kê
- [ ] Thêm chức năng xuất CSV
- [ ] Viết tests cho tính năng quản lý

**Kiểm thử**:
- Request tests cho edit/update
- System test: chỉnh sửa trước phiếu
- System test: chỉnh sửa bị chặn sau phiếu
- System test: đóng poll thủ công

### Giai đoạn 6: Background Jobs & Quản Lý Thời Hạn (P2 - Quan trọng)

**Thời gian**: 1-2 ngày  
**Sản phẩm**:
- [ ] Tạo CloseExpiredPollsJob
- [ ] Cấu hình recurring task Solid Queue
- [ ] Triển khai thực thi thời hạn
- [ ] Thêm giám sát job
- [ ] Viết job tests

**Kiểm thử**:
- Kiểm thử đơn vị job
- Kiểm thử tích hợp: poll đóng đúng thời hạn
- System test: bỏ phiếu bị chặn sau thời hạn

### Giai đoạn 7: Polish & Sẵn Sàng Sản Xuất (Bắt buộc)

**Thời gian**: 2-3 ngày  
**Sản phẩm**:
- [ ] Thêm styling Tailwind CSS
- [ ] Triển khai thiết kế responsive
- [ ] Thêm tính năng accessibility (nhãn ARIA, điều hướng bàn phím)
- [ ] Tối ưu hiệu năng (caching, eager loading)
- [ ] Tăng cường bảo mật (giới hạn tốc độ Rack::Attack)
- [ ] Kiểm thử production trên Render.com
- [ ] Cập nhật tài liệu

**Kiểm thử**:
- Kiểm thử accessibility (screen reader, bàn phím)
- Kiểm thử responsive mobile (iOS, Android)
- Kiểm thử tải (100 người dùng đồng thời)
- Kiểm thử smoke production

## Đánh Giá Rủi Ro

| Rủi Ro | Tác Động | Giảm Thiểu |
|--------|----------|------------|
| Lách quy tắc bỏ phiếu trùng | Cao | Dấu vân tay đa lớp (IP + UA + session), giới hạn tốc độ |
| Race conditions khi đếm phiếu | Trung bình | Giao dịch atomic database, khóa counter cache |
| Hiệu năng broadcast thời gian thực | Trung bình | Fragment caching, giới hạn tần số broadcast 2s |
| Lỗi job deadline | Cao | Độ tin cậy Solid Queue, giám sát job, logic retry |
| Xung đột access code poll | Thấp | 8-char base64 = 2^48 tổ hợp, ràng buộc uniqueness |
| Session hijacking cho bỏ phiếu | Trung bình | Chỉ HTTPS, session cookies an toàn, bảo vệ CSRF |

## Tiêu Chí Thành Công

- [ ] Tất cả 15 yêu cầu chức năng (FR-001 đến FR-015) đã triển khai
- [ ] Tất cả 10 tiêu chí thành công (SC-001 đến SC-010) đã xác thực
- [ ] Độ bao phủ kiểm thử ≥90% trên models và controllers
- [ ] Tất cả 4 user stories (P1, P1, P2, P3) hoàn thành với acceptance tests
- [ ] Đáp ứng tiêu chuẩn hiệu năng (< 60s tạo poll, < 15s bỏ phiếu, < 2s cập nhật thời gian thực)
- [ ] Không lỗ hổng bảo mật (quét Brakeman sạch)
- [ ] Thiết kế responsive hoạt động trên iOS và Android
- [ ] Triển khai thành công lên Render.com

## Các Bước Tiếp Theo

1. **Đánh giá Kế hoạch**: Nhóm đánh giá kế hoạch kỹ thuật này để phản hồi
2. **Nghiên cứu Giai đoạn 0** (nếu cần): Tạo research.md cho mục NEEDS CLARIFICATION
3. **Thực thi Giai đoạn 1**: Bắt đầu với schema database và triển khai model
4. **Tạo Tasks**: Chạy `/speckit.tasks` để tạo tasks triển khai chi tiết
5. **Bắt đầu Phát triển**: Theo quy trình TDD, triển khai tính năng P1 trước

---

**Trạng Thái Kế Hoạch**: ✅ SẴN SÀNG TRIỂN KHAI  
**Thời gian Ước tính**: 12-16 ngày (tính năng P1-P2), +3-4 ngày cho tính năng P3  
**Năng lực Nhóm**: 1-2 lập trình viên
