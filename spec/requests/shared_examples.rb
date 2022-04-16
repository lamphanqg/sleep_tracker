RSpec.shared_examples "a successful request" do
  it "returns ok" do
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples "a not found error" do
  it "returns not found" do
    expect(response).to have_http_status(:not_found)
  end
end

RSpec.shared_examples "a bad request error" do
  it "returns bad request" do
    expect(response).to have_http_status(:bad_request)
  end
end
