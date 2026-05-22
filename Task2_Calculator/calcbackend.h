#ifndef CALCBACKEND_H
#define CALCBACKEND_H

#include <QObject>
#include <QString>

class CalcBackEnd : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString inputText READ getinputText WRITE setInputText NOTIFY inputTextChanged FINAL)
    Q_PROPERTY(QString outputText READ getoutputText WRITE setOutputText NOTIFY outputTextChanged FINAL)




public:
    explicit CalcBackEnd(QObject *parent = nullptr);

    Q_INVOKABLE void calculate();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void deleteChar();


    QString getinputText() const;
    void setInputText(const QString &newInputText);

    QString getoutputText() const;
    void setOutputText(const QString &newOutputText);

signals:


    void inputTextChanged();

    void outputTextChanged();

private:

    QString m_inputText;
    QString m_outputText;
};

#endif // CALCBACKEND_H
