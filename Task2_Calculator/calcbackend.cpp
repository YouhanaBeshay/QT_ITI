#include "calcbackend.h"


// TODO: Ask if QJSEngine is better than using external lib (exprtk)

// #include <QRegularExpression>
// #include <QJSEngine>
// #include <cmath>


#include <exprtk.hpp>
#include <cmath>

CalcBackEnd::CalcBackEnd(QObject *parent)
    : QObject{parent}
{}

QString CalcBackEnd::getinputText() const
{
    return m_inputText;
}

void CalcBackEnd::setInputText(const QString &newInputText)
{
    if (m_inputText == newInputText)
        return;
    m_inputText = newInputText;
    emit inputTextChanged();
}

QString CalcBackEnd::getoutputText() const
{
    return m_outputText;
}

void CalcBackEnd::setOutputText(const QString &newOutputText)
{
    if (m_outputText == newOutputText)
        return;
    m_outputText = newOutputText;
    emit outputTextChanged();
}


//== Using QJSEngine

// void CalcBackEnd::calculate()
// {
//     QString expr = m_inputText;
//     expr.replace(QChar(0x00D7), "*")   // ×
//         .replace(QChar(0x00F7), "/")   // ÷
//         .replace(QChar(0x2212), "-")   // −
//         .replace(QRegularExpression("(\\d)\\("), "\\1*(")  // 2( → 2*(
//         .replace(")(", ")*(");

//     QJSEngine engine;
//     QJSValue result = engine.evaluate(expr);

//     if (result.isError())
//         setOutputText("Syntax Error");
//     else {
//         double val = result.toNumber();
//         if (std::isinf(val) || std::isnan(val))
//             setOutputText("Math Error");
//         else
//             setOutputText(result.toString());
//     }
// }


//== Using ExprTk
void CalcBackEnd::calculate()
{
    QString expr = m_inputText;
    expr.replace(QChar(0x00D7), "*")   // ×
        .replace(QChar(0x00F7), "/")   // ÷
        .replace(QChar(0x2212), "-");  // −

    // ExprTk works with std::string
    std::string exprStr = expr.toStdString();

    exprtk::expression<double> expression;
    exprtk::parser<double> parser;

    if (exprStr.empty()) {
        setOutputText("");
        return;
    }

    if (!parser.compile(exprStr, expression)) {
        setOutputText("Syntax Error");
        return;
    }

    double result = expression.value();

    if (std::isinf(result) || std::isnan(result))
        setOutputText("Math Error");
    else {
        // show as integer if no fractional part
        if (result == std::floor(result))
            setOutputText(QString::number(static_cast<long long>(result)));
        else
            setOutputText(QString::number(result, 'g', 10)); // 10 digits precision
    }
}

void CalcBackEnd::clear()
{
    m_inputText = "";
    emit inputTextChanged();

    m_outputText = "";
    emit outputTextChanged();
}

void CalcBackEnd::deleteChar()
{
    if (!m_inputText.isEmpty()) {
        m_inputText.chop(1); // chop (delete) the last character
        emit inputTextChanged();

        m_outputText = "";
        emit outputTextChanged();
    }
}
