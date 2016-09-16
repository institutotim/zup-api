require 'spec_helper'

describe UserMailer do
  let(:user)    { create(:user) }
  let(:report)  { create(:reports_item, user: user) }
  let(:comment) { create(:reports_comment) }
  let(:status)  { report.status }

  before do
    ENV['WELCOME_USER_MAILER_MESSAGE'] = 'welcome message'
  end

  describe 'send_password_recovery_instructions' do
    let(:mail) { described_class.send_password_recovery_instructions(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pedido de Recuperação de Senha')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['suporte@zeladoriaurbana.com.br'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Para começar o processo de recuperação de sua senha, por favor, clique no link abaixo:')
      expect(mail.body.encoded).to match('Caso você não tenha efetuado o pedido de recuperação de senha, apenas ignore este e-mail.')
    end
  end

  describe 'welcome' do
    context 'with randon password' do
      subject { described_class.welcome(user, 'password') }

      it 'should set correct subject' do
        expect(subject.subject).to eq('Você está cadastrado')
      end

      it "should send email to user's mail" do
        expect(subject.to).to eq([user.email])
      end

      it 'sender should be the default' do
        expect(subject.from).to eq(['suporte@zeladoriaurbana.com.br'])
      end

      it 'should send correct welcome messages' do
        expect(subject.body.encoded).to match('welcome message')
      end

      it 'should send password' do
        expect(subject.body.encoded).to match('<strong>Foi criada uma senha temporária para o seu cadastro: </strong>password')
      end

      it 'should notify to change the password' do
        expect(subject.body.encoded).to match('Recomendamos que você entre em seu perfil imediatamente e altere a sua senha.')
      end
    end

    context 'without randon password' do
      subject { described_class.welcome(user) }

      it 'should set correct subject' do
        expect(subject.subject).to eq('Você está cadastrado')
      end

      it "should send email to user's mail" do
        expect(subject.to).to eq([user.email])
      end

      it 'sender should be the default' do
        expect(subject.from).to eq(['suporte@zeladoriaurbana.com.br'])
      end

      it 'should send correct welcome messages' do
        expect(subject.body.encoded).to match('welcome message')
      end

      it 'should not send password' do
        expect(subject.body.encoded).not_to match('<strong>Foi criada uma senha temporária para o seu cadastro: </strong>')
      end

      it 'should not notify to change the password' do
        expect(subject.body.encoded).not_to match('Recomendamos que você entre em seu perfil imediatamente e altere a sua senha.')
      end
    end
  end

  describe 'notify_report_status_update' do
    let(:mail) { described_class.notify_report_status_update(report) }

    it 'renders the headers' do
      expect(mail.subject).to eq("O status da sua solicitação foi alterado para '#{status.title}'")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['suporte@zeladoriaurbana.com.br'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Confira a atualização e o resumo da sua solicitação')
      expect(mail.body.encoded).to match(status.title)
    end
  end

  describe 'notify_report_comment' do
    let(:mail) { described_class.notify_report_comment(report, comment) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Um novo comentário foi feito na sua solicitação')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['suporte@zeladoriaurbana.com.br'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Protocolo #{report.protocol}")
      expect(mail.body.encoded).to match(comment.message)
      expect(mail.body.encoded).to match(comment.author.name)
    end
  end

  describe '#notify_report_creation' do
    let(:mail) { described_class.notify_report_creation(report) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Recebemos sua solicitação')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['suporte@zeladoriaurbana.com.br'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Protocolo #{report.protocol}")
      expect(mail.body.encoded).to match(status.title)
    end
  end
end
